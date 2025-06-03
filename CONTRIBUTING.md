# Contributing to Traefik Manager

Thank you for your interest in contributing to Traefik Manager! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

- Use the [GitHub Issues](https://github.com/fwartner/traefik-manager/issues) page
- Search existing issues before creating a new one
- Provide clear reproduction steps and system information
- Include relevant error messages and logs

### Suggesting Features

- Open a GitHub issue with the "enhancement" label
- Describe the use case and expected behavior
- Explain why this feature would benefit users

### Code Contributions

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/your-feature-name`
4. **Make** your changes
5. **Test** your changes thoroughly
6. **Commit** with descriptive messages
7. **Push** to your fork
8. **Open** a Pull Request

## 🛠️ Development Setup

### Prerequisites

- Node.js 18+ and npm 8+
- Git
- A Traefik configuration directory for testing

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/traefik-manager.git
cd traefik-manager

# Install dependencies
npm install

# Start development server
npm run dev

# Access at http://localhost:3000
```

### Environment Setup

Create a `.env` file for local development:

```bash
NODE_ENV=development
TRAEFIK_CONFIG_DIR=/path/to/test/traefik/config
PORT=3000
```

## 📝 Code Guidelines

### Code Style

- Follow existing code patterns and conventions
- Use TypeScript for type safety
- Use Vue 3 Composition API
- Follow Nuxt 3 best practices
- Use Tailwind CSS for styling

### File Structure

```
├── components/          # Vue components
├── composables/         # Vue composables
├── pages/              # Nuxt pages (routes)
├── server/api/         # API endpoints
├── utils/              # Utility functions
└── assets/             # Static assets
```

### API Endpoints

- Follow RESTful conventions
- Use appropriate HTTP methods
- Return consistent JSON responses
- Include proper error handling

### Component Guidelines

- Use single file components (.vue)
- Props should be typed with TypeScript
- Emit events for parent communication
- Use composables for shared logic

## 🧪 Testing

### Manual Testing

- Test all CRUD operations for hosts
- Verify TLS toggle functionality
- Test error handling scenarios
- Check responsive design on different screen sizes

### Before Submitting

- Run type checking: `npm run typecheck`
- Test the production build: `npm run build && npm run preview`
- Verify Docker build works (if applicable)

## 📋 Pull Request Guidelines

### PR Requirements

- Reference related issues
- Include a clear description of changes
- Add screenshots for UI changes
- Update documentation if needed

### PR Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Manual testing completed
- [ ] No TypeScript errors
- [ ] Production build works

## Screenshots (if applicable)
Add screenshots for UI changes
```

### Review Process

- PRs require review from a maintainer
- Address feedback promptly
- Keep commits clean and well-documented
- Squash commits if requested

## 🔧 Technical Details

### Dependencies

- **Nuxt 3**: Full-stack framework
- **Vue 3**: Frontend framework
- **Tailwind CSS**: Styling
- **TypeScript**: Type safety
- **js-yaml**: YAML parsing for Traefik configs

### Architecture

- Server-side API endpoints handle file operations
- Client-side composables manage state
- Components are atomic and reusable
- Traefik configurations stored as YAML files

### Security Considerations

- Validate all user inputs
- Sanitize file paths and names
- Don't expose sensitive system information
- Follow principle of least privilege

## 🐛 Debugging

### Common Issues

- **Port conflicts**: Change PORT in .env
- **Permission errors**: Check file system permissions
- **Module errors**: Delete node_modules and reinstall

### Logging

- Use `console.log` for development debugging
- Server-side logs appear in terminal
- Client-side logs appear in browser console

## 📚 Resources

- [Nuxt 3 Documentation](https://nuxt.com/docs)
- [Vue 3 Documentation](https://vuejs.org/guide/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 💬 Questions?

- Open a GitHub Discussion
- Contact: florian@wartner.io
- Check existing issues and documentation first

---

Thank you for contributing to Traefik Manager! 🚀