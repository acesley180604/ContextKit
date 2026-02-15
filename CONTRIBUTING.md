# Contributing to ContextKit

Thank you for your interest in contributing to ContextKit! We welcome contributions from the community.

## Getting Started

1. **Fork the repository** and clone it locally
2. **Create a branch** for your feature or bug fix
3. **Make your changes** with clear commit messages
4. **Test your changes** thoroughly
5. **Submit a pull request** with a clear description

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/contextkit.git
cd contextkit

# Open in Xcode
open Package.swift

# Run tests
swift test
```

## Code Guidelines

- **Swift Style**: Follow Swift API Design Guidelines
- **Documentation**: Add doc comments for public APIs
- **Tests**: Include unit tests for new features
- **Performance**: Context capture must be < 10ms
- **Permissions**: Never add features requiring permissions

## Testing

```bash
# Run all tests
swift test

# Run specific test
swift test --filter ContextKitTests.TimeContextTests
```

## Pull Request Process

1. Update README.md if adding new features
2. Update documentation in code comments
3. Ensure all tests pass
4. Update CHANGELOG.md with your changes
5. Request review from maintainers

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## Questions?

- Open an issue for bugs or feature requests
- Join our Discord for discussions
- Email support@contextkit.dev for questions

Thank you for contributing! 🎉
