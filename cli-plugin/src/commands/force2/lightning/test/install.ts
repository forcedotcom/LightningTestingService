import { flags, SfdxCommand } from '@salesforce/command';
import { Messages, SfdxError } from '@salesforce/core';
import * as request from 'request';
import PackageInstallCommand = require('salesforce-alm/dist/lib/package/packageInstallCommand');

// Initialize Messages with the current plugin directory
Messages.importMessagesDirectory(__dirname);

// Load the specific messages for this file. Messages from @salesforce/command, @salesforce/core,
// or any library that is using the messages framework can also be loaded this way.
const messages = Messages.loadMessages('aura-test', 'install');

export default class Install extends SfdxCommand {
  public static description = messages.getMessage('commandDescription');
  public static descriptionLong = messages.getMessage('commandDescriptionLong');

  public static examples = [
    '$ sfdx force:lightning:test:install',
    '$ sfdx force:lightning:test:install -w 0 -r v1.0',
    'sfdx force:lightning:test:install -t jasmine'
  ];

  protected static flagsConfig = {
    // flag with a value (-n, --name=VALUE)
    releaseversion: flags.string({
      char: 'r',
      description: messages.getMessage('releaseversionFlagDescription'),
      longDescription: messages.getMessage('releaseversionFlagDescriptionLong')
    }),
    packagetype: flags.boolean({
      char: 't',
      description: messages.getMessage('packagetypeFlagDescription'),
      longDescription: messages.getMessage('packagetypeFlagDescriptionLong')
    }),
    wait: flags.number({
      char: 'w',
      description: messages.getMessage('waitFlagDescription'),
      longDescription: messages.getMessage('waitFlagDescriptionLong')
    })
  };

  // Comment this out if your command does not require an org username
  protected static requiresUsername = true;

  // Set this to true if your command requires a project workspace; 'requiresProject' is false by default
  protected static requiresProject = true;

  private packageInstallCommand = new PackageInstallCommand();

  public async run(): Promise<unknown> {
    const org = this.org;

    const releaseVersion =
      this.flags.releaseversion && this.flags.releaseversion !== 'latest'
        ? `tags/${this.flags.releaseversion}`
        : 'latest';
    const uri = `https://api.github.com/repos/forcedotcom/LightningTestingService/releases/${releaseVersion}`;

    return new Promise((resolve, reject) => {
      request(
        {
          headers: {
            'User-Agent': 'LTS'
          },
          uri
        },
        (err, res, body) => {
          if (err) {
            return reject(new SfdxError(err.message));
          }

          if (res.statusCode !== 200) {
            this.logger.debug(
              `Unable to reach ${uri}. statusCode=${res.statusCode}, response body=${body}`
            );
            return reject(
              new SfdxError(
                messages.getMessage('packageIdRetrievalIssue', [uri])
              )
            );
          }

          const content = JSON.parse(body);
          if (content.message === 'Not Found') {
            return reject(
              new SfdxError(
                messages.getMessage('invalidVersion', [releaseVersion])
              )
            );
          }

          const packagetype = this.flags.packagetype
            ? this.flags.packagetype.toLowerCase()
            : 'full';
          let name;
          if (packagetype === 'jasmine') {
            name = 'jasmine';
          } else if (packagetype === 'mocha') {
            name = 'mocha';
          } else if (packagetype === 'full') {
            name = 'examples';
          } else {
            return reject(
              new SfdxError(messages.getMessage('invalidType', [packagetype]))
            );
          }

          const regEx = new RegExp(
            `\\[.*${name}.*\\]\\(.*p0=(\\w{15}).*\\)`,
            'i'
          );
          const releaseMsg = content.body;
          const regExMatch = regEx.exec(releaseMsg);
          let id;
          if (regExMatch && regExMatch.length === 2) {
            id = regExMatch[1];
          } else {
            this.logger.debug(
              `Unable to map test framework to package id using the release description, ${releaseMsg}`
            );
            return reject(
              new SfdxError(
                messages.getMessage('packageIdExtractionIssue', [uri])
              )
            );
          }

          const ctx = {
            org,
            flags: {
              id,
              wait: this.flags.wait ? this.flags.wait : 2,
              securitytype: 'AllUsers'
            }
          };

          return resolve(this.packageInstallCommand.execute(ctx));
        }
      );
    });
  }
}
