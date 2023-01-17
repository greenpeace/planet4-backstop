# Greenpeace Planet4 BackstopJS Docker Container

![Planet4](./planet4.png)

## Introduction

### What is it?

This repository contains an implementation of BackstopJS and the scripts that create a Docker container which is used for visual regression testing in Planet4 websites.


## How to build it

### In circleCI
Any git tag will create a new version of the docker image, tagged with the circleCI build number and "latest".

Any commit to a branch will create a new version of the docker image, tagged with the circleCI build number and the name of the branch.

The docker image that gets build will then be pushed to the docker hub repository: [greenpeaceinternational/planet4-backstop](https://hub.docker.com/r/greenpeaceinternational/planet4-backstop)

### Locally
- Define a directory in your filesystem where backstop data will be stored. (Not the directory of this repository)
- cd to that directory
- Export the path of that directory to the variable LOCAL_BACKSTOP_DATA by running
`export LOCAL_BACKSTOP_DATA=$(pwd)`
- Define the variables APP_HOSTNAME and APP_HOSTPATH for the website that should be crawled
example: `export APP_HOSTNAME=www.greenpeace.org` and `export APP_HOSTPATH=international`
- cd back to the directory of this repository
- Run `make prepare` to generate Dockerfile.
- Run `make build` to create a local image.
- RUN `make dev-history` to create reference screenshots of the homepage of the website
- Run `make dev-compare` to test against it 


## How it works
In Planet4 site repositories there are circleCI workflows starting with `backstop`.

Before the build process the `backstop-history` is triggered. It does the following 

  - It does a checkout of the planet4-nro
  - It checks if a file named `backstop-pages.json` exists
  - If it exists, it merges it to the default `backstop.json` (With this process each NRO can have differnt pages tested on top of the default ones)
  - It creates screenshots for these pages
  
After the build process the `backstop-compare` is triggered. It does the following

  - It does all the steps that the backstop-history does, but it also:
  - It takes new screenshots
  - It compares them to the ones from the previous step
  - It generates a report (available via the artifacts of the circleCI job) of the comparisons
  

## How you can define pages to your own NRO site for testing:
Add a file called `backstop-pages.json` with a key `scenarios`. The format and available options can be seen at the backstopjs [documentation](https://github.com/garris/BackstopJS#advanced-scenarios).
The simplest form of the file should include a label and a URL for each page, like the following: 
```
{
  "scenarios": [
    {
      "label": "Planet4 KoyanSync Explore page",
      "url": "https://APP_HOSTNAME/APP_HOSTPATH/explore/"
    }
  ]
}
```

## How you can test different sizes: 
Currently the sizes are hardcoded at the file (in this repository) backstop.json: 

- width: 320, height: 480
- width: 1024, height: 768

You can add extra view ports there, but they will be used in all Planet4 websites. 

If you want to add extra viewports to one site only, you can do it via the backstop-pages.json by adding something like that:
```$xslt
  "viewports": [
    {
      "label": "widescreen",
      "width": 1366,
      "height": 768
    }
  ]
```

So, a setup with multiple extra pages and an extra viewport would look like that:
```$xslt
{
  "viewports": [
    {
      "label": "widescreen",
      "width": 1366,
      "height": 768
    }
  ],
  "scenarios": [
    {
      "label": "Explore page",
      "url": "https://APP_HOSTNAME/APP_HOSTPATH/explore/"
    },
    {
      "label": "About page",
      "url": "https://APP_HOSTNAME/APP_HOSTPATH/about/"
    }
  ]
}

```

Please be very careful, as any viewport or page you add multiplies the number of screenshot that are taken, and things could get out of hand easily.
(For example, the default has 1 page X 2 viewports, and takes 2 screenshots. By adding the above 1 viewport and 2 pages, we have in total 3 X 3 = 9 screenshots)

## Contribute

Please read the [Contribution Guidelines](https://planet4.greenpeace.org/handbook/dev-contribute-to-planet4/) for Planet4.
