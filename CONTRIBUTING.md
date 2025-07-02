# Contributing to Git AutoCommit Script

Thank you for your interest in contributing! This guide will help you get started.

## How to Contribute

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/your-username/gitAutocommit.git
cd gitAutocommit
```

### Create a Branch

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or a bugfix branch
git checkout -b bugfix/issue-description
```

### 3. Make Changes

Follow the coding standards and test your changes thoroughly.

## Coding Standards

### Bash Script Guidelines

- Use 4 spaces for indentation
- Add comments for complex logic
- Use meaningful variable names
- Follow the existing error handling pattern

```bash
# Good
check_prerequisites() {
    local missing_tools=()
    # Check for required commands
}

# Avoid
chk_pre() {
    # No explanation
}
```

### Function Documentation

Each function should have a clear purpose:

```bash
# Description: Validates that all required tools are installed
# Returns: Exits with error code 1 if tools are missing
check_prerequisites() {
    # Implementation
}
```

## Testing

### Manual Testing Checklist

Before submitting, test these scenarios:

- [ ] Basic commit with file changes
- [ ] Custom commit message
- [ ] Dry run mode
- [ ] Verbose output
- [ ] Format-only mode
- [ ] Undo functionality
- [ ] Error handling (no git repo, no changes, etc.)
- [ ] Push with merge conflicts

### Test Commands

```bash
# Test basic functionality
./gPusher.sh -d

# Test with custom message
./gPusher.sh -d "Test commit message"

# Test formatting only
./gPusher.sh -f

# Test verbose mode
./gPusher.sh -v -d
```

## Bug Reports

### Bug Report Template

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Run command: `./gPusher.sh`
2. Expected behavior vs actual behavior

**Environment**
- OS: [e.g., Ubuntu 20.04, macOS 12]
- Bash version: [e.g., 5.0.17]
- Git version: [e.g., 2.34.1]

**Additional Context**
Any relevant logs or screenshots
```

## Feature Requests

### Feature Request Template

```markdown
**Feature Description**
Clear description of the proposed feature

**Use Case**
Why would this feature be useful?

**Proposed Implementation**
How do you envision this working?

**Examples**
Code examples or usage scenarios
```

## Pull Request Process

### PR Checklist

- [ ] Code follows the project's style guidelines
- [ ] Self-review completed
- [ ] Manual testing performed
- [ ] Documentation updated (if needed)
- [ ] Commit messages are clear and descriptive

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Manual testing completed
- [ ] All scenarios from testing checklist verified

## Screenshots (if applicable)
Add screenshots of terminal output
```

## 📋 Development Setup

### Environment Setup

```bash
# Install development dependencies
sudo apt-get install shellcheck  # For script linting

# Make the script executable
chmod +x gPusher.sh

# Test in a sample repository
mkdir test-repo && cd test-repo
git init
echo "test" > test.txt
../gPusher.sh -d
```

### Code Linting

```bash
# Check script syntax and style
shellcheck gPusher.sh

# Fix common issues
shellcheck -f diff gPusher.sh | patch
```

## Areas for Contribution

### High Priority

- Support for additional programming languages (Python, JavaScript, etc.)
- Configuration file support
- Integration with different Git hosting platforms
- Performance optimizations

### Medium Priority

- Additional output formats
- Plugin system for custom formatters
- Better error messages
- Interactive mode

### Low Priority

- GUI wrapper
- Integration with IDEs
- Statistics and analytics

## Resources

### Learning Resources

- [Bash Scripting Guide](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [Git Documentation](https://git-scm.com/docs)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

### Similar Projects

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Commitizen](https://github.com/commitizen/cz-cli)
- [Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special thanks in project documentation

## Getting Help

- Open an issue for questions
- Start discussions for feature ideas
- Check existing issues before creating new ones

---

Thank you for contributing to make Git workflows more efficient!
