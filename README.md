<div align = "center">

<h1><a href="https://2kabhishek.github.io/ghpm">ghpm</a></h1>

<a href="https://github.com/2KAbhishek/ghpm/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/ghpm?style=plastic&color=white&label=License"> </a>

<a href="https://github.com/2KAbhishek/ghpm/pulse">
<img alt="Updated" src="https://img.shields.io/github/last-commit/2kabhishek/ghpm?style=plastic&color=e30724&label=Updated"> </a>

<a href="https://github.com/2KAbhishek/ghpm/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/ghpm?style=plastic&color=00d451&label=Stars"></a>

<a href="https://github.com/2KAbhishek/ghpm/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/ghpm?style=plastic&color=1688f0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/ghpm/watchers">
<img alt="Watchers" src="https://img.shields.io/github/watchers/2kabhishek/ghpm?style=plastic&color=ff5500&label=Watchers"> </a>

<a href="https://github.com/2KAbhishek/ghpm/graphs/contributors">
<img alt="Contributors" src="https://img.shields.io/github/contributors/2kabhishek/ghpm?style=plastic&color=f0f&label=Contributors"> </a>

<a href="https://github.com/2KAbhishek?tab=followers">
<img alt="Followers" src="https://img.shields.io/github/followers/2kabhishek?color=222&style=plastic&label=Followers"> </a>

<h3>The GitHub Project Manager 🧑‍💻⚙️</h3>

<figure>
  <img src= "images/screenshot.jpg" alt="ghpm Demo" style="width:100%">
  <br/>
  <figcaption>ghpm screenshot</figcaption>
</figure>

</div>

## What is this

ghpm is a `<utility/tool/feature>` that allows `<insert_target_audience>` to do `<action/task_it_does>`.

## Inspiration

ghpm was inspired by `<reason/idea>`.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- You have installed the latest version of `bash`
- Cloning self repos needs authentication and relies on `gh`, the github cli

## Getting ghpm

To install ghpm, follow these steps:

```bash
git clone https://github.com/2kabhishek/ghpm.git
cd ghpm
# Setup symlink make sure target directory is added to PATH
ln -sfnv $PWD/ghpm.sh ~/Applications/bin/ghpm
```

## Using ghpm

After symlinking, you can run `ghpm` in your GitHub repos parent directory or you can pass it in as an argument

```bash
ghpm
# or
ghpm ~/Projects/GitHub
```

This will open up the self guided menu with a list of operations you can perform.

> You can use option 3 to run any command in all your GitHub repos, very useful for push, pull and similar commands.

## How it was built

ghpm was built using `bash`

## Challenges faced

Figuring out the GitHub api and authentication was a challenge, I used `gh` to do some of the heavy lifting.

## What I learned

- Best practices for `bash` scripts
- Bash functions and how it handles variables
- Used `awk`, `find`, `xargs` and other useful tools.


Hit the ⭐ button if you found this useful.

## More Info

<div align="center">

<a href="https://github.com/2KAbhishek/ghpm">Source</a> | <a href="https://2kabhishek.github.io/ghpm">Website</a>

</div>
