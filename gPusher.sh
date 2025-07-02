#!/bin/bash

#===============================================================================
# git-autocommit.sh - Automated Git Workflow Script
#===============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BOLD}USAGE:${NC}"
    echo -e "  ${BLUE}$(basename "$0")${NC} [option] [custom message]"
    echo
    echo -e "${BOLD}OPTIONS:${NC}"
    echo -e "  ${GREEN}-h, --help${NC}    Show this help message and exit"
    echo -e "  ${GREEN}-v, --verbose${NC} Display detailed Git status and recent commits"
    echo -e "  ${GREEN}-d, --dry-run${NC} Perform a dry run without committing"
    echo -e "  ${GREEN}-u, --undo${NC}    Undo the last commit"
    echo -e "  ${GREEN}-f, --format${NC}  Only format files without committing"
    echo -e "  ${GREEN}-m \"message\"${NC}  Use a custom commit message"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ${BLUE}$(basename "$0")${NC} \"Fixed memory leak in parser\""
    echo -e "  ${BLUE}$(basename "$0")${NC} -v \"Updated documentation\""
    echo -e "  ${BLUE}$(basename "$0")${NC} --undo"
}

print_status() {
    local type=$1
    local message=$2
    
    case "$type" in
        "info")    echo -e "${CYAN}[INFO]${NC} $message" ;;
        "success") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "warning") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "error")   echo -e "${RED}[ERROR]${NC} $message" ;;
        "task")    echo -e "${PURPLE}[TASK]${NC} $message" ;;
        *)         echo -e "$message" ;;
    esac
}

check_prerequisites() {
    local missing_tools=()
    
    for cmd in git realpath clang-format; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_tools+=("$cmd")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_status "error" "Missing required tools: ${missing_tools[*]}"
        echo -e "Please install the missing tools and try again."
        exit 1
    fi
}

check_git_repo() {
    ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$ROOT_DIR" ]; then
        print_status "error" "Not inside a Git repository."
        exit 1
    fi
    REL_PATH=$(realpath --relative-to="$ROOT_DIR" "$PWD")
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" == "HEAD" ]; then
        print_status "error" "Not on a valid Git branch. You might be in a detached HEAD state."
        exit 1
    fi
    
    print_status "info" "Working in repository: ${BOLD}$(basename "$ROOT_DIR")${NC}"
    print_status "info" "Current path: ${BLUE}$REL_PATH${NC}"
    print_status "info" "Current branch: ${YELLOW}$CURRENT_BRANCH${NC}"
}

format_code(){
    print_status "task" "Formatting C/C++ source files..."
    local file_count=0
    
    cat > .clang-format << EOF
---
Language: Cpp
BasedOnStyle: LLVM
IndentWidth: 4
UseTab: Never
BreakBeforeBraces: Attach
IndentCaseLabels: true
SpaceBeforeParens: ControlStatements
SpacesInParentheses: false
AlignTrailingComments: true
BreakBeforeBinaryOperators: None
ColumnLimit: 100
IndentPPDirectives: None
SpaceAfterCStyleCast: false
SpaceBeforeAssignmentOperators: true
IndentWrappedFunctionNames: false
AlwaysBreakAfterReturnType: None
ContinuationIndentWidth: 4
PointerAlignment: Right
KeepEmptyLinesAtTheStartOfBlocks: false
MaxEmptyLinesToKeep: 1
EOF
    
    while IFS= read -r file; do
        clang-format -i -style=file "$file"
        ((file_count++))
    done < <(find . -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) -not -path "*/build/*" -not -path "*/\.*/*")
    
    if [ "$file_count" -gt 0 ]; then
        print_status "success" "Applied clang-format to $file_count C/C++ files."
    else
        print_status "info" "No C/C++ files found to format."
    fi
}

check_for_changes() {
    if git diff-index --quiet HEAD -- && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        print_status "info" "No changes to commit."
        return 1
    fi
    return 0
}

get_changes_details() {
    local added_files=$(git ls-files --others --exclude-standard)
    local modified_files=$(git diff --name-only)
    local deleted_files=$(git ls-files --deleted)
    
    local added_count=$(echo "$added_files" | grep -v '^$' | wc -l)
    local modified_count=$(echo "$modified_files" | grep -v '^$' | wc -l)
    local deleted_count=$(echo "$deleted_files" | grep -v '^$' | wc -l)
    
    local details=""
    
    if [ "$modified_count" -gt 0 ]; then
        details="${details}Modified files:\n"
        local file_list=$(echo "$modified_files" | head -10)
        details="${details}$(echo "$file_list" | sed 's/^/- /')\n"
        
        if [ "$modified_count" -gt 10 ]; then
            details="${details}...and $((modified_count - 10)) more modified files\n"
        fi
        details="${details}\n"
    fi
    
    if [ "$added_count" -gt 0 ]; then
        details="${details}Added files:\n"
        local added_list=$(echo "$added_files" | head -10)
        details="${details}$(echo "$added_list" | sed 's/^/+ /')\n"
        
        if [ "$added_count" -gt 10 ]; then
            details="${details}...and $((added_count - 10)) more added files\n"
        fi
        details="${details}\n"
    fi
    
    if [ "$deleted_count" -gt 0 ]; then
        details="${details}Deleted files:\n"
        local deleted_list=$(echo "$deleted_files" | head -10)
        details="${details}$(echo "$deleted_list" | sed 's/^/- /')\n"
        
        if [ "$deleted_count" -gt 10 ]; then
            details="${details}...and $((deleted_count - 10)) more deleted files\n"
        fi
    fi
    
    echo -e "$details"
}

generate_commit_message() {
    local custom_msg="$1"
    local added_files=$(git ls-files --others --exclude-standard)
    local modified_files=$(git diff --name-only)
    local deleted_files=$(git ls-files --deleted)
    local commit_msg=""
    local commit_desc=""
    
    local added_count=$(echo "$added_files" | grep -v '^$' | wc -l)
    local modified_count=$(echo "$modified_files" | grep -v '^$' | wc -l)
    local deleted_count=$(echo "$deleted_files" | grep -v '^$' | wc -l)
    local total_count=$((added_count + modified_count + deleted_count))
    
    commit_desc=$(get_changes_details)
    
    if [ "$total_count" -eq 1 ]; then
        local file_path=""
        local action=""
        
        if [ "$added_count" -eq 1 ]; then
            file_path="$added_files"
            action="add"
        elif [ "$modified_count" -eq 1 ]; then
            file_path="$modified_files"
            action="edit"
        elif [ "$deleted_count" -eq 1 ]; then
            file_path="$deleted_files"
            action="delete"
        fi
        
        local file_name=$(basename "$file_path")
        local dir_name=$(dirname "$file_path")
        
        if [ "$dir_name" = "." ]; then
            commit_msg="[$action][$REL_PATH/$file_name] $action $file_name"
        else
            commit_msg="[$action][$REL_PATH/$dir_name] $action $file_name in $dir_name"
        fi
    else
        local common_dir=""
        
        local all_files="$added_files
$modified_files
$deleted_files"
        
        local all_dirs=$(echo "$all_files" | grep -v '^$' | xargs -I{} dirname {} | sort | uniq -c | sort -nr)
        
        if [ -n "$all_dirs" ]; then
            common_dir=$(echo "$all_dirs" | head -n 1 | sed 's/^ *[0-9]* *//')
        else
            common_dir="."
        fi
        
        if [ "$common_dir" = "." ]; then
            commit_msg="[update][$REL_PATH] Updated multiple files"
        else
            commit_msg="[update][$REL_PATH/$common_dir] Updated files in $common_dir"
        fi
        
        if [ -n "$commit_desc" ]; then
            commit_msg="$commit_msg

$commit_desc

--"
        fi
    fi
    
    if [ -n "$custom_msg" ]; then
        commit_msg="[solved][$REL_PATH] $custom_msg"
    fi
    
    echo "$commit_msg"
}

commit_changes() {
    local commit_msg="$1"
    local dry_run="$2"
    
    print_status "task" "Adding all changes to staging area..."
    git add .
    
    echo
    echo -e "${BOLD}Modified files:${NC}"
    git status --short | sed 's/^M/\\033[0;32mM\\033[0m/' | sed 's/^A/\\033[0;34mA\\033[0m/' | sed 's/^D/\\033[0;31mD\\033[0m/' | sed 's/^R/\\033[0;35mR\\033[0m/' | sed 's/^??/\\033[0;33m??\\033[0m/' | xargs -I{} echo -e "{}"
    echo
    
    if [ "$dry_run" = true ]; then
        print_status "info" "Dry run - would commit with message: '${BOLD}$commit_msg${NC}'"
        return 0
    fi
    
    print_status "task" "Committing changes with message: '${BOLD}$commit_msg${NC}'"
    if git commit -m "$commit_msg"; then
        print_status "success" "Changes committed successfully!"
    else
        print_status "error" "Failed to commit changes."
        return 1
    fi
    
    return 0
}

push_changes() {
    print_status "task" "Pushing changes to remote repository..."
    
    if git push origin "$CURRENT_BRANCH" 2>/dev/null; then
        print_status "success" "Changes pushed to ${YELLOW}$CURRENT_BRANCH${NC} successfully!"
    else
        print_status "warning" "Push failed. Attempting to pull and rebase..."
        
        if git pull --rebase; then
            print_status "info" "Successfully pulled and rebased with remote."
            
            if git push origin "$CURRENT_BRANCH"; then
                print_status "success" "Changes pushed to ${YELLOW}$CURRENT_BRANCH${NC} after rebase!"
            else
                print_status "error" "Failed to push even after rebase. You may need to resolve conflicts manually."
                return 1
            fi
        else
            print_status "error" "Failed to pull and rebase. You may need to resolve conflicts manually."
            return 1
        fi
    fi
    
    return 0
}

undo_last_commit() {
    local last_commit=$(git log -1 --pretty=format:"%s")
    
    print_status "task" "Undoing last commit: '${BOLD}$last_commit${NC}'"
    if git reset --soft HEAD~1; then
        print_status "success" "Last commit undone. Changes have been unstaged."
    else
        print_status "error" "Failed to undo last commit."
        return 1
    fi
    
    return 0
}

show_verbose_info() {
    echo
    echo -e "${BOLD}${PURPLE}=== Git Status ===${NC}"
    git -c color.status=always status | sed '1,3d'
    
    echo
    echo -e "${BOLD}${PURPLE}=== Recent Commits ===${NC}"
    git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -5
    echo
}

main() {
    check_git_repo
    
    local custom_msg=""
    local verbose=false
    local dry_run=false
    local do_undo=false
    local format_only=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -u|--undo)
                do_undo=true
                shift
                ;;
            -f|--format)
                format_only=true
                shift
                ;;
            -m)
                if [[ -n "$2" && "$2" != -* ]]; then
                    custom_msg="$2"
                    shift 2
                else
                    print_status "error" "Option -m requires an argument."
                    exit 1
                fi
                ;;
            *)
                # Treat as custom message if not starting with dash
                if [[ "$1" != -* ]]; then
                    custom_msg="$1"
                else
                    print_status "error" "Unknown option: $1"
                    echo "Use --help to see available options."
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    if [ "$do_undo" = true ]; then
        undo_last_commit
        exit $?
    fi
    
    format_code
    
    if [ "$format_only" = true ]; then
        print_status "success" "Formatting completed. No changes were committed."
        exit 0
    fi
    
    if ! check_for_changes; then
        exit 0
    fi
    
    local commit_msg=$(generate_commit_message "$custom_msg")
    
    if ! commit_changes "$commit_msg" "$dry_run"; then
        exit 1
    fi
    
    if [ "$dry_run" = true ]; then
        exit 0
    fi
    
    push_changes
    
    if [ "$verbose" = true ]; then
        show_verbose_info
    fi
    
    print_status "success" "All tasks completed successfully!"
}

main "$@"
