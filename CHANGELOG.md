# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.0.0] - 2024-05-13
### Added
- Ability to reload the browse menu

### Changed
- Photos that failed to download can no longer be downloaded

### Fixed
- Escape key being read extra times and closng menus prematurely
- Gallery being inescapable when there's nothing present
- Camera acting weird when there's not enough photos to fit the screen
- Landscape photos pushing text offscreen


## [0.4.1] - 2024-05-09
### Added
- Menu descriptions when hovering over buttons in main menu

### Fixed
- Deselecting photo in gallery menu completely exited the menu


## [0.4.0] - 2024-05-09
### Added
- Search menu in the gallery menu to find photos easier
- Instructions on how to navigate the gallery menu

### Changed
- Layout of gallery menu

### Fixed
- Crash when the gallery is first used
- Crash when no data for a photo is found
- Text flowing off the screen


## [0.3.1] - 2024-05-08
### Fixed
- Crashes when first attempting to save photos because the "gallery" folder doesn't initially exist


## [0.3.0] - 2024-05-07
### Added
- Ability to download photos from [TheCatAPI](https://thecatapi.com/) along with a nickname and a note

### Changed
- General UI to be more colorful
- Switch from jpg to png in gallery storage

### Fixed
- Mouse scroll wheel listener wasn't being removed upon exiting the browse menu
- Volume controls popping up while typig


## [0.2.0] - 2024-05-01
### Added
- Main menu with a silly spinning cat that goes "boing!"
- Gallery menu to browse saved photos
- Transitions between menus

### Changed
- Photos to be synchronized when entering the browsing menu
- Project structure to match future plans

### Fixed
- Photos not being destroyed and clogging memory when the browse menu was closed

### Security
- Moved CatAPI key to actual system enviroment instead of an internal hashmap


## [0.1.0] - 2024-04-17
### Added
- Add menu to browse TheCatAPI