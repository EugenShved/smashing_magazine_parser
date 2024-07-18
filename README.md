## AI Wallpaper Downloader

The Smashing Magazine website publishes desktop wallpapers every month. Let's automate the task of checking and downloading wallpapers for a specific theme for a given month. So, we need to write a CLI utility that will download all wallpapers matching the specified theme for the specified month-year into the user's current directory. Here are all the [wallpapers](https://www.smashingmagazine.com/category/wallpapers), and here are the [wallpapers for July 2024](https://www.smashingmagazine.com/2024/06/desktop-wallpaper-calendars-july-2024/).

### Conditions

- Ruby 3+
- Third-party libraries
- Ruby Style Guide (Shopify)
- ~~Anthropic Claude (provides $5 credit)~~
- Please set up Chat GPT key [here](https://github.com/EugenShved/smashing_magazine_parser/blob/main/lib/image_analyzer.rb#L7)
- Tests coverage more than 60%

It is assumed that the wallpaper download script will be run with parameters, for example:

```
/smashing.rb --month 022024 --theme animals
```

or
```
./smashing.rb --month 042024 --theme flowers
```

### Features

* The utility should download wallpapers in all available resolutions
* If wallpapers are available in versions with and without a calendar, the utility should download both.
