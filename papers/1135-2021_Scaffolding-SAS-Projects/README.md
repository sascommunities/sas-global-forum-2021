---
PAPER_TITLE: Scaffolding SAS® Projects With NPM and SASjs
PAPER_AUTHORS: Allan Bowe
PAPER_NUMBER: 1135-2021
LAUNCH_CMD1: # follow instructions in /workspace/sas-global-forum-2021/tools/notebook-to-pdf/README.md and run below from THAT directory
LAUNCH_CMD2: python3 app.py --markdown-file /workspace/sas-global-forum-2021/papers/1135-2021_Scaffolding-SAS-Projects/README.md --output-dir /workspace/sas-global-forum-2021/papers/1135-2021_Scaffolding-SAS-Projects
---

## ABSTRACT

Is your SAS scattered across SAS folders, local directories and server file systems?
Are your deliverables delayed by the need to build tools?
Does your deployment process involve manual steps?

The SASjs framework enables code consistency across teams and projects, de-risks the use of shared tools and dependencies, and facilitates continuous deployment to SAS environments. The framework can be applied to SAS® Viya® jobs, SAS® 9 Stored Processes, and even regular SAS programs on a file system.

Join this session and learn how to create (scaffold) a SASjs project, add a job, add a macro dependency, add a program (include) dependency, add job init and term files, deploy the jobs to SAS, and run them as part of a flow. I will share the secret of how to deploy to SAS Viya without a client and secret. And, the entire demo will be performed from a local text editor (VSCode).


## INTRODUCTION

If you are a SAS Developer with two or more projects under your belt, you'll be familiar with the fact that SAS affords incredible flexibility when it comes to development and deployment.  Every company has different standards, and even you yourself have probably developed some coding habits that are not shared by your colleagues.

As it happens, this same situation applies also to JS (JavaScript) - a flexible and loosely typed language, often mis-used to create spaghetti projects that are hard to maintain and difficult to debug. 

In response to this situation, various frameworks have evolved that 'wrap around' JS to provide structure and consistency in the way projects are built - such as React, Angular, and Vue.  This is great for application owners, making it easier to on-board new developers, and reducing the total cost of ownership, whilst maintaining development velocity as application complexity increases.


The goal of SASjs is to provide such a framework for SAS - a structure, set of opinions, and suite of productivity tools.  This enables developers to spend more time on the things that matter - ie, rapid delivery of business value, to any SAS platform, in a repeatable and scalable fashion.

In this paper we walk through the process of setting up a SASjs project in terms of:

* deployment
* execution
* documentation
* testing


## THE SASjs FRAMEWORK
The SASjs Framework itself is a set of tools that abstracts away the common complexities of a typical SAS deployment.  Each of these tools can be used individually, or together as part of a cohesive and integrated approach to managing the SAS application lifecycle - ie project setup, development, compilation, deployment, execution, testing, documentation, and more.


The core components are:

* [sasjs/adapter](https://adapter.sasjs.io) - handles SASLogon authentication and communication between frontend and backend
* [sasjs/cli](https://cli.sasjs.io) - a Command Line Interface for automating common tasks
* [sasjs/core](https://core.sasjs.io) - a library with over 120 SAS macros geared towards application developers

Other components include:

* [sasjs/vscode-extension](https://marketplace.visualstudio.com/items?itemName=SASjs.sasjs-for-vscode) - SAS code execution, syntax highlighting and linting in the VS Code IDE
* [sasjs/lint](https://github.com/sasjs/lint) - the linter is used in both the VS Code extension and the SASjs CLI
* numerous [seed apps](https://github.com/search?q=topic%3Asasjs-seed-app+org%3Asasjs+fork%3Atrue) ready to kick start a SAS project

There are even a series of [ready-made apps](https://sasjs.io/apps), built using the framework.


## GETTING STARTED

There are some pre-requisites to install before continuing:

* NPM.  This provides the run-time for the CLI.  Instructions for the portable version are [here](https://sasjs.io/windows/#NPM).
* GIT.  Not strictly necessary but highly recommended, and git-bash provides unix-like commands in windows.
* VS Code. You could use other IDEs, however this is the one primarily supported by SASjs.  

For most of the rest of this paper we will be submitting terminal commands.  If you are working in VS Code you may wish to change your default terminal to git-bash - to do this, open Terminal (Terminal/New Terminal), choose "select default profile" and select "git bash" from the list of options.

To check you have everything installed correctly, try running:

``` bash
npm -v
```

 This should return a version number.  If not, go back and check your installation of NodeJS (did you add the correct folder to your PATH if running the portable version?  If in VS Code, did you try re-opening the editor?)


If you have a version number, you are ready to install the SASjs CLI.  Simply run:

```bash
npm i -g @sasjs/cli
```

This will install the SASjs CLI globally, such that you can run the `sasjs` command from any directory.  You can verify this by running:

```bash
sasjs v
```

This will return the version number.  So - now that we have the CLI - we can get properly started!

## SASjs CREATE

This command is used to create an initial project, from a template.  We'll use the jobs template.  Run the following commands to create a project called "sgf2021" and move into that directory.

```bash
sasjs create sgf2021 -t jobs
cd sgf2021
```

Here you will see a number of files:

| File/Folder        | Description|
|--------------------|----------------------------|
| db                 | This folder contains the DDL for creating the various libraries.  It is split with one subfolder per libref.                                                                         |
| .git               | System folder for managing GIT history                                                                                                                                               |
| .github            | Contains example github actions should you wish to perform automated SASjs checks, eg as part of a pull request or merge                                                             |
| .gitignore         | List of files and folders to be ignored by GIT (won't be committed to source control)                                                                                                |
| .gitpod.dockerfile | Used for gitpod demos, can be ignored / removed                                                                                                                                      |
| .gitpod.yml        | Used for gitpod demos, can be ignored / removed                                                                                                                                      |
| includes           | Default location for SAS Programs to be %included in SAS Jobs, Services, or Tests                                                                                                    |
| jobs               | Main parent folder containing jobinit.sas and jobterm.sas as well as subdirectories for SAS Jobs                                                                                     |
| macros             | Default location for SAS Macros                                                                                                                                                      |
| node_modules       | System folder for storing third party packages, such as @sasjs/core                                                                                                                  |
| package.json       | Main config file for the repo, lists all the project dependencies as well as example scripts (npm run SCRIPTNAME) and project metadata                                               |
| package-lock.json  | System file for managing dependencies of dependencies                                                                                                                                |
| README.md          | The main page describing your project.  Is also used as the homepage when running `sasjs doc`.                                                                                       |
| sasjs              | The folder containing the `sasjsconfig.json` file, which contains the settings for the entire project - such as where the various files are located (both locally and remotely).     |
| .sasjslint         | Settings used when checking SAS Jobs, Services, Tests, Macros and Programs for code quality issues such as encoded passwords, trailing spaces, macros without parentheses, etc etc.  |
| tests              | Alternative location for storing tests.  Normally we recommend that tests live alongside the relevant Job/Service/Macro, eg jobname.test.sas or macroname.test.sas                   |
| .vscode            | Folder containing VSCode dependencies, such as the default 80 char ruler, and the recommendation to use the SASjs extension.                                                         |
|||

This project is 'ready to build' however to explain the process, let's add a new job.

### Adding a Job
To add a job, simply add an "any_name_you_like.sas" file to any of the folders listed in the "sasjs/sasjsconfig.json" `jobFolders` array.  You could create a new folder to put it in (listed in this array) or use an existing one - such as jobs/load.

All SAS files in SASjs **must** have a Doxygen header.  This enables the automatic documentation which we'll cover in `sasjs doc`.

The header looks like this:

```sas
/**
  @file
  @brief one line description of the job
  @details Multiline description of the job.
  You can write markdown here and it will be properly
  rendered in the HTML docs.

      data code must be;
        indented = 4 * spaces;
      run;

  <h4> SAS Macros </h4>
  @li example.sas

  <h4> SAS Includes </h4>
  @li someprogram.sas

  <h4> Data Inputs </h4>
  @li somelib.ds1
  @li somelib.ds2

  <h4> Data Outputs </h4>
  @li tgtlib.bigmuvvads

**/
```

For a longer description of Doxygen, please see Paper


### SUB SECTION

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## CONCLUSION

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## ACKNOWLEDGMENTS

Thanks to everyone for reading this!

## RECOMMENDED READING

All the book!

## CONTACT INFORMATION

Your comments and questions are valued and encouraged. Contact the author at:

> Allan Bowe
> Email: allan.bowe@analytium.co.uk

SAS and all other SAS Institute Inc. product or service names are registered trasemarks or trademarks of SAS Institue Inc. in the USA and other Countries &reg; indiciates USA registration.

Other brand and product names are trademarks of their respective companies.

## REFERENCES

[//]: # ""You only need to add references here that you haven't automatically added or referenced using Zoreto.""



