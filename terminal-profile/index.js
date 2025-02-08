import { argbFromHex, hexFromArgb, themeFromSourceColor } from "@material/material-color-utilities";

/** @enum {string} */
const ColorName = {
  black: 'black',
  red: 'red',
  green: 'green',
  yellow: 'yellow',
  blue: 'blue',
  purple: 'purple',
  cyan: 'cyan',
  white: 'white',
  brightBlack: 'brightBlack',
  brightRed: 'brightRed',
  brightGreen: 'brightGreen',
  brightYellow: 'brightYellow',
  brightBlue: 'brightBlue',
  brightPurple: 'brightPurple',
  brightCyan: 'brightCyan',
  brightWhite: 'brightWhite',
  background: 'background',
  selectionBackground: 'selectionBackground',
  foreground: 'foreground',
}

/** @enum {number} */
const XtermColors = {
  // Colors taken from xterm.
  // https://github.com/xterm-x11/xterm-snapshots/blob/5b7a08a3482b425c97610190228e58b51ac6c39b/vttests/88colors2.pl#L160-L175
  black: argbFromHex("#000000"),
  red: argbFromHex("#CD0000"),
  green: argbFromHex("#00CD00"),
  yellow: argbFromHex("#CDCD00"),
  blue: argbFromHex("#0000EE"),
  purple: argbFromHex("#CD00CD"),
  cyan: argbFromHex("#00CDCD"),
  white: argbFromHex("#E5E5E5"),
  brightBlack: argbFromHex("#7F7F7F"),
  brightRed: argbFromHex("#FF0000"),
  brightGreen: argbFromHex("#00FF00"),
  brightYellow: argbFromHex("#FFFF00"),
  brightBlue: argbFromHex("#5C5CFF"),
  brightPurple: argbFromHex("#FF00FF"),
  brightCyan: argbFromHex("#00FFFF"),
  brightWhite: argbFromHex("#FFFFFF"),
}

class Profile {
  /**
   * @param {string} colorScheme
   */
  constructor(colorScheme) {
    this.colorScheme = colorScheme;
  }
}

class Scheme {
  /**
   * @param {string} name
   * @param {import("@material/material-color-utilities").Theme} theme
   * @param {boolean} isDark
   */
  constructor(name, theme, isDark) {
    const scheme = isDark ? theme.schemes.dark : theme.schemes.light;

    this.name = Scheme.themeNameMode(name, isDark);
    this.background = hexFromArgb(scheme.surface);
    this.selectionBackground = hexFromArgb(scheme.surfaceVariant);
    this.foreground = hexFromArgb(scheme.onSurface);
    this.black = Scheme.findColor(theme.customColors, ColorName.black, isDark);
    this.red = Scheme.findColor(theme.customColors, ColorName.red, isDark);
    this.green = Scheme.findColor(theme.customColors, ColorName.green, isDark);
    this.yellow = Scheme.findColor(theme.customColors, ColorName.yellow, isDark);
    this.blue = Scheme.findColor(theme.customColors, ColorName.blue, isDark);
    this.purple = Scheme.findColor(theme.customColors, ColorName.purple, isDark);
    this.cyan = Scheme.findColor(theme.customColors, ColorName.cyan, isDark);
    this.white = Scheme.findColor(theme.customColors, ColorName.white, isDark);
    this.brightBlack = Scheme.findColor(theme.customColors, ColorName.brightBlack, isDark);
    this.brightRed = Scheme.findColor(theme.customColors, ColorName.brightRed, isDark);
    this.brightGreen = Scheme.findColor(theme.customColors, ColorName.brightGreen, isDark);
    this.brightYellow = Scheme.findColor(theme.customColors, ColorName.brightYellow, isDark);
    this.brightBlue = Scheme.findColor(theme.customColors, ColorName.brightBlue, isDark);
    this.brightPurple = Scheme.findColor(theme.customColors, ColorName.brightPurple, isDark);
    this.brightCyan = Scheme.findColor(theme.customColors, ColorName.brightCyan, isDark);
    this.brightWhite = Scheme.findColor(theme.customColors, ColorName.brightWhite, isDark);
  }

  /**
   * @param {string} themeName
   * @param {boolean} isDark
   */
  static themeNameMode(themeName, isDark) {
    return `${themeName} ${isDark ? 'Dark' : 'Light'}`;
  }

  /**
   * @param {Array<import("@material/material-color-utilities").CustomColorGroup>} customColors
   * @param {ColorName} color
   * @param {boolean} isDark
   */
  static findColor(customColors, color, isDark) {
    const customColor = customColors.find(
      (value, _index, _obj) => value.color.name == color);
    if (customColor === undefined) {
      throw new Error(`Color ${color} not found`);
    }

    return isDark ? hexFromArgb(customColor.dark.color) : hexFromArgb(customColor.light.color);
  }
}

class WindowsTerminalProfile {
  /**
   * @param {Array<Profile>} profiles
   * @param {Array<Scheme>} schemes
   */
  constructor(profiles, schemes) {
    this.profiles = profiles;
    this.schemes = schemes;
  }
}

function main() {
  const themeName = 'Arch Linux Material';

  // Arch Linux logo blue color.
  const sourceColor = argbFromHex('#1793d1');

  // Get the theme from a hex color.
  const theme = themeFromSourceColor(sourceColor,
    [
      {
        name: ColorName.black,
        value: XtermColors.black,
        blend: true,
      },
      {
        name: ColorName.red,
        value: XtermColors.red,
        blend: true,
      },
      {
        name: ColorName.green,
        value: XtermColors.green,
        blend: true,
      },
      {
        name: ColorName.yellow,
        value: XtermColors.yellow,
        blend: true,
      },
      {
        name: ColorName.blue,
        value: XtermColors.blue,
        blend: true,
      },
      {
        name: ColorName.purple,
        value: XtermColors.purple,
        blend: true,
      },
      {
        name: ColorName.cyan,
        value: XtermColors.cyan,
        blend: true,
      },
      {
        name: ColorName.white,
        value: XtermColors.white,
        blend: true,
      },
      {
        name: ColorName.brightBlack,
        value: XtermColors.brightBlack,
        blend: true,
      },
      {
        name: ColorName.brightRed,
        value: XtermColors.brightRed,
        blend: true,
      },
      {
        name: ColorName.brightGreen,
        value: XtermColors.brightGreen,
        blend: true,
      },
      {
        name: ColorName.brightYellow,
        value: XtermColors.brightYellow,
        blend: true,
      },
      {
        name: ColorName.brightBlue,
        value: XtermColors.brightBlue,
        blend: true,
      },
      {
        name: ColorName.brightPurple,
        value: XtermColors.brightPurple,
        blend: true,
      },
      {
        name: ColorName.brightCyan,
        value: XtermColors.brightCyan,
        blend: true,
      },
      {
        name: ColorName.brightWhite,
        value: XtermColors.brightWhite,
        blend: true,
      },
    ]);

  const profile = new WindowsTerminalProfile(
    new Array(new Profile(Scheme.themeNameMode(themeName, true))),
    new Array(new Scheme(themeName, theme, true), new Scheme(themeName, theme, false)));

  console.log(JSON.stringify(profile, null, 2));
}

main();
