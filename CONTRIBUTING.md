# Contributing

> [!WARNING]  
> This guide is a work in progress and may not be complete.

This is a basic contributing guide and is a work in progress.

## Workflow

1. Fork the repository.
2. Create a branch in your fork!
3. Make your changes.
4. [Test](#Testing) your changes.
5. Commit and push your changes.
6. Create a PR to this repository.
7. Verify the tests pass, otherwise resolve.
8. Make sure to keep your branch up-to-date.

## Testing

GitHub is easier to set up, but you have to push your commits to test.  
Running locally is harder to set up, but it is much easier to test; and by far recommended!

### GitHub

Add your secrets to GitHub Actions Secrets.

When you push your branch to your repository, the [test.yaml](.github/workflows/test.yaml) should run...

### Locally

To run actions locally you need to install act: https://nektosact.com/installation/index.html

1. Create a `.secrets` file with all your secrets in .env file format.
2. Run: `act -j test`

To skip half the tests (`-e event.json`) and print your secrets (insecure) run:  
`act -j test --insecure-secrets -e event.json`

To see all available jobs run: `act -l`

For more information see the documentation: https://nektosact.com/usage/index.html
