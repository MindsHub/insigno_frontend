# Meta folder

This folder contains files related to the insigno_frontend repository that do not really have something to do with the app itself, for example assets used in the README or logo projects.

## The colors used for the logo

- `#d4ffb6` light green background
- `#80b900` green trash can foreground
- `#8fce0f` green mindshub foreground
- `#e74c3c` (red of original mindshub, not used in the logo)
- `#375200` dark green used for text in play store banner

## Generating the launcher icon

The launcher icon can be generated using [IconKitchen](https://icon.kitchen). These are the parameters that were used. Things that are different from defaults were highlighted.
- **Icon: Image**, then drop `logo.svg` on the area that appears or select it from the filesystem
- Scaling: Center
- Mask: none
- Effect: None
- **Padding: 1%**
- Background type: Color
- **Background color: `#d4ffb6`** from above
- Texture: None
- Badge: none
- Filename: none (defaults to `ic_launcher`)
- **Shape: Squircle**
- Themed: no

Then tap the `+` at the top to add "Play Store Banner (Beta)". Tap on it to change its parameters.
- Title: "Insigno"
- Tagline: "by MindsHub"
- Font: Roboto
- BG: `#d4ffb6` from above
- Text: `#375200` from above
- Icon: enabled
- Layout: Horizontal
- Shape: Squircle
