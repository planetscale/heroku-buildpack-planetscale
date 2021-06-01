# Heroku Buildpack for PlanetScale CLI

This is a Heroku buildpack for adding Planetscale CLI into your project.

![PlanetScale CLI](https://user-images.githubusercontent.com/155044/118568235-66c8e380-b745-11eb-8124-5a72e17f7f7b.png)

## Usage

Add this buildpack to your Heroku project

```
heroku buildpacks:add https://github.com/planetscale/heroku-buildpack-planetscale
```

The command will install [`pscale` CLI](https://github.com/planetscale/heroku-buildpack-planetscale) into your Heroku application.

This buildpack also supports installing a specific cli version by setting the `PSCALE_CLI_VERSION` environment variable.

```
heroku config:set PSCALE_CLI_VERSION=0.40.0
```

## Documentation

For more information about buildpacks, see these Heroku Dev Center articles

- [Buildpacks](https://devcenter.heroku.com/articles/buildpacks)
- [Buildpack API](https://devcenter.heroku.com/articles/buildpack-api)
