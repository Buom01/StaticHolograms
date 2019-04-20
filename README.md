# StaticHolograms
A [Cuberite](https://cuberite.org/) plugin finally bringing hologram !

## Supported features

  - [x] Creating / Edition / Removal / ...
  - [x] Colors with `&`
  - [ ] Multiline (Need to extend Cuberite API to get proper integration)
  - [ ] Floating item (Same that above)
  - [ ] Interaction with hologram / item hologram  (Integrating glowing item could be great)

No complexe thing like animation are planned. For not Keep It Simple and Stupid.

## Drawbacks

  - The plugin don't store anything by himself, it's only a tool to create invisible and nammed armor stand. It also mean that the plugin could be saftly disabled when not needed.
  - It also implie that getting a list of hologram or manipulating them need the concerned chunks to be loaded

## Installation
  Go in server's plugin directory and `git clone https://github.com/Buom01/StaticHolograms`
  Then add in your server's `settings.ini`, under `[Plugins]` a line like `Plugin=StaticHolograms`

## Usage
`/sholograms [list|add|remove|move|edit] <id> <x> <y> <z> <text>`

Examples:

- Listing : `/sholograms list`
- Creation : `/sholograms add 0 80 0 &cIt works !`
- Removal : `/sholograms remove <id>` (The ID is provided when listing or just after the creation)
