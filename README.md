# animate-backgrounds

## tl;dr

Animate CSS `background-image` gradients, `background-position`, and `background-size` using jQuery or AnimeJS

Check out the [docs][docs] for interactive examples

Check out the [interactive tool][tool] for animating and customizing gradient patterns

## Dependencies

- Animation engine: hooks into either jQuery or a hook-enabled [version][animejs_hooks] of AnimeJS
- the AnimeJS version depends on (and includes) [`tinycolor2`](https://github.com/bgrins/TinyColor)
- the jQuery version depends on (you must include) [`jquery-color`](https://github.com/jquery/jquery-color)

## Installation

You can use `npm` or a `<script>` tag to include the animation handlers for either jQuery or AnimeJS.

#### for jQuery

##### `<script>` tag

Include the following `<script>` tag *after* jQuery and jQuery Color:

`<script src='https://unpkg.com/animate-backgrounds/animate-backgrounds.jquery.js'></script>`

##### using `npm`

Install `jquery`, `jquery-color`, and `animate-backgrounds` packages:

`npm install --save jquery github:jquery/jquery-color animate-backgrounds`
> The latest npm-released version of `jquery-color` doesn't
> [seem](https://github.com/jquery/jquery-color/issues/84) to work correctly
> so I recommend installing `jquery-color` from Github as above

Then load in your code via `require()` or `import`:

`require('animate-backgrounds/animate-backgrounds.jquery')`

#### for AnimeJS

##### `<script>` tag

Include the following `<script>` tags for the hook-enabled version of AnimeJS and the background animation hooks themselves:
```
<script src='https://unpkg.com/animejs-hooks/anime.min.js'></script>
<script src='https://unpkg.com/animate-backgrounds/animate-backgrounds.anime.js'></script>
```

##### using `npm`

Install `animejs-hooks` (hook-enabled version of `animejs`) and `animate-backgrounds` packages:

`npm install --save animejs-hooks animate-backgrounds`

Then load in your code via `require()` or `import`:

`require('animate-backgrounds/animate-backgrounds.anime')`

## Usage

Once the hooks for `jQuery` or `AnimeJS` have been loaded (by one of the means described above),
you can animate `background-image` gradients (`linear-gradient()`/`radial-gradient()`/`repeating-linear-gradient()`/`repeating-radial-gradient()`), `background-position`, and/or `background-size` like you would any other CSS property (ie by specifying the desired end CSS value). Or you can use [shorthand syntax](#shorthand-syntax) to just declaratively specify the desired changes from the initial value

## Examples

See [here][docs] for interactive examples of how to animate different aspects of gradients,
`background-size` and `background-position` using your choice of jQuery vs AnimeJS and
standard vs shorthand syntax

## Shorthand syntax

Since gradients tend to be verbose and `background-image`/`background-position`/`background-size` can have multiple values, a shorthand syntax is supported that allows you to just specify the desired changes from the initial CSS property value

#### start -> end

If you want all occurrences of some given value (ie a color, position/length, angle) inside your initial CSS property value to animate to a corresponding end value, you can declaratively specify that using the syntax `start -> end`

For example, to animate a linear gradient from `linear-gradient(90deg, red, green, blue)` to `linear-gradient(180deg, red, yellow, blue)` (using jQuery):
```
$('.el')
.animate({
  backgroundImage: '90deg -> 180deg, green -> yellow'
})
```

If you have multiple background images, by default these apply to all of them.
Also, the shorthand syntax allows you to specify changes on separate lines rather than comma-separated

So if this is your starting `background-image` CSS value:
```
.el {
    background-image:
      radial-gradient(circle at 50% 50%, magenta 40px, transparent 40px),
      radial-gradient(circle at 0% 50%, dodgerblue 20px, transparent 40px);
}
```
And you want to animate to this ending value:
```
radial-gradient(circle at 80% 80%, magenta 30px, rgba(255, 255, 255, 0.3) 30px),
radial-gradient(circle at 0% 80%, dodgerblue 20px, rgba(255, 255, 255, 0.3) 30px)
```
Then you can specify this animation using eg:
```
$('.el')
.animate({
  backgroundImage: `
    50% -> 80%
    transparent -> rgba(255, 255, 255, 0.3)
    40px -> 30px
  `
})
```

#### [index]

But say in the above example, you only want to change the gradient position of the first gradient (to `circle 80% 80%`)
and only change `transparent -> rgba(255, 255, 255, 0.3)` in the second gradient.
Ie instead you want to animate to:
```
radial-gradient(circle at 80% 80%, magenta 30px, transparent 30px),
radial-gradient(circle at 0% 50%, dodgerblue 20px, rgba(255, 255, 255, 0.3) 30px)
```
Then you can use `[index]` syntax to restrict the subsequent declarations to just that background image (counting from a zero-based index).
So you could express the desired animation like so:
TODO: make this example in anime?
```
$('.el')
.animate({
  backgroundImage: `
    40px -> 30px
    [0] 50% -> 80%
    [1] transparent -> rgba(255, 255, 255, 0.3)
  `
})
```

TODO: example of specifying full stop change
TODO: example showing multiple animated properties (eg `background-image` and `background-position`)

You should be able to use this shorthand syntax to specify any desired changes to individual values within your animated
`background-image` gradients, `background-position` and/or `background-size`.
Of course, if you find it simpler/more convenient, you can always use the traditional syntax,
supplying the full desired CSS property value as the animation target value.

## Gradients: what can I animate?
- Any colors, positions (ie stop positions, radial gradient start position), and/or angles (ie linear gradient direction) should be animatable
- Animating color opacity is supported. You can specify target values using `rgba()` syntax. You can animate to/from `transparent`.
  `transparent` is equivalent to `rgba(0, 0, 0, 0)` (TODO: is this right?) so to only animate a color's opacity, you may want to explicitly specify a fully
   opaque version of your color as your start or end value. Eg if fading out `#f00`, you may want to specify the target value as `rgba(255, 0, 0, 0)`
   so that your color doesn't shift while the opacity is animating
- You must have the same number of color stops (per respective gradient) in your target value as in your start value (when using traditional syntax).
  So to "add a new color stop" during the animation, at this point you have to include a dummy extra color stop in your start value
  corresponding to where you're going to introduce the new color stop in the end value
  TODO: example?
- You must have the same number of background images in your start and end values (when using traditional syntax).
  So if you have a mixture of gradients and actual images as the element's `background-image`, you must supply all of them
- You can't animate between radial gradient shape or extent keywords (eg `circle -> ellipse` or `closest-side -> farthest-side`
- You can't animate between values with different units (eg `90deg -> 1turn`, `10% -> 50px`)
- You can, however, animate between positional keywords and percent-valued locations (eg `top` -> `10%`)
  or directional keywords and angle values (eg `to bottom -> 45deg`)

## Simultaneous gradient animations

Sometimes you may wish to animate different aspects of gradients at the same time.
If those aspects have the same timing (delay, duration, easing) then you can just specify
them as a single animation.
But if they don't, you can instruct the animations not to get in each other's way by
starting your target `backgroundImage` value with `simultaneous `
(this works for either standard or shorthand syntax).

See [here][docs_simultaneous] for an interactive example of using the `simultaneous` flag.

> The `simultaneous` flag can make your animation slightly less performant
> so I'd recommend only using when you actually have another "overlapping" animation of the
> same `backgroundImage` property running at the same time.
> Basically the gradient animation code always uses a diff
> (ie only the parts of the gradient that are actually changing)
> as its representation of the end value.
> By default it uses the start value to "fill in" the unchanging parts of the gradient
> as the animation runs.
> But by using `simultaneous` it will check and use the current value (from the DOM)
> each time the animation updates, thus avoiding clobbering changes made by other
> simultaneous animations but also costing a bit more (b/c of the DOM reads)

TODO: unsupported syntax?
TODO: background-position and background-size can take a single value (and "multiply" it)

## LICENSE

MIT

[docs]: http://helixbass.net/projects/animate_backgrounds
[docs_simultaneous]: http://helixbass.net/projects/animate_backgrounds
[tool]: http://helixbass.net/projects/gradients
[animejs_hooks]: https://github.com/helixbass/animejs-hooks
