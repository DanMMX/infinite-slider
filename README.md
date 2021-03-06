infinite-slider
==============

If you'd like to contribute to this project, PRs are appreciated.
If you have any bugs, reports are welcomed.


In the Wild
===========

infinite-slider is being used in the following websites. ([add your website to this list](https://github.com/gilbox/infinite-slider/edit/master/README.md))

- [American Express Travel Mobile Site](http://m.amextravel.com/)
- [iSeatz](http://iseatz.com/)
- [Hookah Club](http://hookah-club.com)

#How do I add this to my project?

You can download infinite-slider by:

* Using bower and running `bower install infinite-slider`
* Or downloading [the zip file](https://github.com/gilbox/infinite-slider/archive/master.zip)


#Dependencies

infinite-slider depends on Angular, [animation-frame](https://github.com/kof/animation-frame), [angular-mousewheel](https://github.com/monospaced/angular-mousewheel) (optional), and [hamsterjs](https://github.com/monospaced/hamster.js) (optional: only needed if you use angular-mousewheel).


# Getting Started

You need the following script tags:

````html
<script src="vendor/AnimationFrame.js"></script>
<script src="vendor/hamster.js"></script> <!-- optional -->
<script src="vendor/mousewheel.js"></script> <!-- optional -->
<script src="infinite-slider.js"></script>
````

Add infinite-slider as a dependency to your app:

````javascript
angular.module('myApp', ['gilbox.infiniteSlider']);
````

Note that in your HTML you may optionally provide the content-width,
otherwise it will be calculated automatically as shown here:

````html
  <div infinite-slider class="infinite-slider-container">
    <div class="infinite-slider-content">

      <!-- content goes here -->

    </div>
  </div>
````

Some minimal styling is required:

````css
.infinite-slider-container {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 400px;
  overflow: hidden;
}

.infinite-slider-content {
  position: absolute;
  z-index: 1;         // note: make sure you set a z-index
  width: 100%;
  height: 400px;
}
````

# Options

## infinite-slider-align="left"

Use this attribute alongside the `infinite-slider` attribute to left-align the slides. 
See the included demo, `left-align.html`.

# Demo

Check out [the demo](http://gilbox.github.io/infinite-slider/demo)

# License

The MIT License

Copyright (c) 2013 Gil Birman http://gilbox.me/

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
