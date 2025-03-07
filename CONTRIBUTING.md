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

Test #1 test password authentication and uses the following secrets:

`secrets.DOCKER_HOST` - SSH Hostname.
`secrets.DOCKER_PORT` - SSH Port.
`secrets.DOCKER_USER` - SSH Username.
`secrets.DOCKER_PASS` - SSH Password.

Test #2 tests both SSH auth and registry auth and runs on GitHub by default.
To test this on GitHub you need to additionally add the following secrets and variables:

`vars.PRIVATE_IMAGE` - Image to your private image.
`vars.DOCKER_HUB_USER` - Private registry username.
`secrets.DOCKER_HUB_PASS` - Private registry password.
`secrets.DOCKER_SSH_KEY` - SSH Private Key.

When you push your branch to your repository, the [test.yaml](.github/workflows/test.yaml) should run...

### Locally

To run actions locally you need to install act: https://nektosact.com/installation/index.html

1. Create a `.secrets` file with all your secrets in .env file format (see [GitHub](#GitHub)).

```shell
act -j test -e event.json
```

The flag `-e event.json` disabled test #2 which tests SSH auth and registry auth.

To test both SSH and authb and registry auth (run test #2) do the following.

1. Create a `.vars` file and add the vars and secrets from test #2 under [GitHub](#GitHub).

Then run the test without the `-e event.json` flag.

```shell
act -j test
```

To print your secrets in plan text (insecure) use `--insecure-secrets`

To see all available jobs run `act -l` and for more details run `act --help`

```shell
act -l
act -j lint
act -j test --insecure-secrets -e event.json
act -j test --env PRIVATE_IMAGE=your/private-image:latest
```

For more information see the documentation: https://nektosact.com/usage/index.html
