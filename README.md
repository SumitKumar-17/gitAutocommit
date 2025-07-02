# Git AutoCommit Script

A powerful Bash script that automates your Git workflow with smart, detailed commit messages that include specific filenames.

## Features

- **Smart Commit Messages**: Automatically generates descriptive commit messages based on your changes
- **Detailed Change Logs**: Lists specific filenames that were modified, added, or deleted
- **Code Formatting**: Optional auto-formatting for C/C++ files using clang-format
- **Colorized Output**: Visually appealing terminal output for better readability
- **Error Handling**: Robust error checking and recovery mechanisms
- **Git Push**: Automatically pushes changes to remote with smart rebase handling
- **Dry Run Mode**: Preview what would happen without making actual changes

## Installation

1. Download the script:

```bash
git clone https://github.com/SumitKumar-17/gitAutocommit
```

2. Make it executable:

```bash
chmod +x gPusher.sh
```

3. Move it somewhere in your PATH (optional):
> **Note**: 
> You can shorten the name of the file like `committer` or`cmit` instead of a long name like here. As you only need to write this name and the rest the script does it.
> I will be using the name `gPusher` here. Change as you like it.

```bash
sudo mv gPusher.sh /usr/local/bin/gPusher
```

## Dependencies

- git
- clang-format (for C/C++ formatting)

> **Note**: 
> I developed this when I was learning C/C++. For any other languages, you can change the `format_code` function as per your needs.

## Usage

```
gPusher [option] [custom message]
```

### Options

- `-h, --help`: Show help message and exit
- `-v, --verbose`: Display detailed Git status and recent commits
- `-d, --dry-run`: Perform a dry run without committing
- `-u, --undo`: Undo the last commit
- `-f, --format`: Only format files without committing
- `-m "message"`: Use a custom commit message

### Examples

#### Basic Usage

Just run the script in your Git repository:

```bash
gPusher
```

This will:
1. Format your C/C++ files (if enabled)
2. Stage all changes
3. Generate a smart commit message
4. Commit the changes
5. Push to the remote repository

#### Custom Commit Message

```bash
gPusher "Fixed memory leak in parser"
```

#### Verbose Mode with Custom Message

```bash
gPusher -v "Updated documentation"
```

#### Dry Run

```bash
gPusher -d
```

#### Undo Last Commit

```bash
gPusher --undo
```

## Commit Message Format

The script generates detailed commit messages that include:

1. A summary line based on the changes or your custom message
2. Detailed lists of exactly which files were:
   - Modified (prefixed with "- ")
   - Added (prefixed with "+ ")
   - Deleted (prefixed with "- ")

Example commit message:

```
[update][MyProject/src] Updated files in src

Modified files:
- src/main.cpp
- src/parser.cpp
- src/utils.h
...and 3 more modified files

Added files:
+ src/new_feature.cpp
+ src/new_feature.h

Deleted files:
- src/deprecated_file.cpp

--
```

## Customization

You can edit the script to customize:
- The formatting command
- The structure of commit messages
- The number of files listed in each category
- Color schemes and output formatting
