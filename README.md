btt-controllers
===============

Controllers for BetterTouchTool widgets. Provides hooks for various services that run in the background.

The source of the included service binaries can be found at [andrewchidden/btt-services](https://github.com/andrewchidden/btt-services).

Article about the preset at [andrewchidden.com](https://andrewchidden.com/long-live-the-macbook-pro-with-touch-bar/).

## Service Hooks

Pre-built binaries and controller scripts for these `btt-service` instances:

- `volume-service`
- `eventkit-service`
- `controlstrip-service`

## Timer App

Simple single-instance timer for the Touch Bar.

## Git Diff

Git diff statistics for a configured working directory.

## Tests

The project uses [Bats](https://github.com/sstephenson/bats) (Bash Automated Testing System) for unit testing shell script logic. The `.bats` test files are located in the `./tests` directory. The Bats binary is not included.

Use `$ bats ./tests` from the project root to run all unit tests, or `$ bats ./tests/a-test-file.bats` to run a particular test file.

- **@warning** Bats cannot handle arbitrary functions when using the built-in `setup` and `teardown` test hooks. As a result, all test cases need to manually call `set_up` and `tear_down`.

## Contributing

Contributions welcomed. Some ground rules:

- Please try to follow the style of the codebase which takes inspiration from [Google’s shell style guide](https://google.github.io/styleguide/shell.xml).
- Add unit tests for all core controller functionality. See the **Tests** section for more information.

## Contact

```
"andrew"
"@"
"andrewchidden.com"
```

## License

Copyright © 2018 CarbonTech Software LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.