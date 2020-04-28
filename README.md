# Manage SSH Keys - GitHub Action
Manage SSH authorized keys from GitHub with GitHub Actions.

This action will
1. Fetch public key from GitHub username e.g. https://github.com/dhsathiya.keys
2. Add provided users in keys.csv to the respective remote machines.

_Note: This action is still under development, but works. Check TODO for more details_

## Why?
I have a lot of local headless machines and I manage lot of remote servers at my company. I get bore when I have to add a user or check the SSH access for someone.

With this action I can centrally monitor who can access what!

## Configuration
1. create workflow directory and add yml file. `.github/workflows/ssh_key.yml`
    ```yml
    on:
      push:
        branches:
          - master
    
    name: Update SSH Keys
    jobs:
      Update-SSH-key:
        name: Update and sync files
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
          with:
            fetch-depth: 2
        - name: Update and sync files
          uses: dhsathiya/action-ssh-keys@master
          env:
            DEPLOY_KEY: ${{secrets.DEPLOY_KEY}}
    ```
2. Create a GitHub secret named `DEPLOY_KEY` and add private key which will be used for `rsync`.
    - Create SSH keys https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

3. Add the respective public key to the `DEPLOY_KEY` on all the machines on which you want to use this action.
4. Create file `default.key` in the GitHub repository root and add the public key in it.
    - This step is necessary, so that the SSH key used by action gets whitelisted on every run.
    - Other reason is, you are using this action because you don't like manual stuff and you also won't like to add the `step 3` key after every run. :wink:

5. Create `keys.csv` file.
    - Simple csv file, field separated with `,`

### `keys.csv` file format
|user@hostname             |/path/to/authorized_keys     |      |      |      |      |
|--------------------------|-----------------------------|------|------|------|------|
|root@dev.sitename.tld     |/root/.ssh/authorized_keys   |user1 |user2 |      |      |
|www-data@prod.sitename.tld|/var/www/.ssh/authorized_keys|user1 |user2 |user3 |user4 |

The action will by default ignore first line.

[Example CSV File](./keys.csv)

## TODO
- [ ] Checks and filters for CSV file fields
- [ ] Only run on diff
- [ ] Fail checks
- [ ] Feature: Direct SSH key support
- [ ] Make action code as per best practices
- [ ] Lighter Docker image
- [ ] [HashiCorp Vault](https://www.vaultproject.io/) Support
- [ ] Publish Action
- [ ] Slack Notification

## License
[MIT](LICENSE) © 2020 Devarshi Sathiya