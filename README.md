# PSTreeGraph

[![Build Status](https://travis-ci.org/epreston/PSTreeGraph.png?branch=master)](https://travis-ci.org/epreston/PSTreeGraph)

PSTreeGraph is a treegraph view control implementation for Cocoa Touch.

This is a port of the sample code from Max OS X to iOS (iPad). 
WWDC 2010 Session 141, “Crafting Custom Cocoa Views”

![](http://farm7.static.flickr.com/6193/6055022105_ab831b2d8e.jpg)


# Example Project

There is an iPad example application to demonstrate the features of PSTreeGraph.


# Status

PSTreeGraph should be considered an viable solution for displaying single parent tree data in an interactive hierarchy.  The "ARC" branch contains the automatic reference counting compatible code base.  In the very near future, this will be merged with "master", non "ARC" code will be frozen at the 1.0 release.  Those looking for a reference counted implementation should look for a "Non ARC 1.0" branch.

This project follows the [SemVer](http://semver.org/) standard. The API may change in backwards-incompatible ways before the 1.0 release.

The goal of PSTreeGraph is to build a high-quality UI control designed specifically for the iPad.  The inspiration / structure comes from WWDC 2010 Session 141, “Crafting Custom Cocoa Views”, an extremely valuable and informative presentation that has proven to be applicable (see this project) to other platforms.


# Getting Started

See [Wiki](https://github.com/epreston/PSTreeGraph/wiki).

Useful information can also be found in the issues log. The following discussions might be helpful. If you can't find what you are looking for, start a new topic.

* [Display hierarchical data from xml or json](https://github.com/epreston/PSTreeGraph/issues/9)
* [Can you select arbitrary nodes?](https://github.com/epreston/PSTreeGraph/issues/5)
* [Customizing the leaf view](https://github.com/epreston/PSTreeGraph/issues/7)


# Known Improvements

See [Milestones](https://github.com/epreston/PSTreeGraph/issues/milestones?with_issues=no).

There are many places where PSTreeGraph could be improved:

* Use GCD to load model data asyncronously.  This control uses a simple protocol implemented by each node in the data model so the control can walk the tree. This can be loaded asynchronously to avoid blocking the main thread when displaying large graphs.

* Cache the bezier path used to render lines in each subtree.  The bezier path used to render the lines between each node in the graph can be cached to improve performance.

* Use CATiledLayer to support much larger graphs.  Investigate using a CATiledLayer to further reduce drawing and memory usage, support scaling, etc. This feature will make it possible support graphs of unlimited size and scale. Rendering time and resource usage would be constant regardless of the number of nodes in the graph.


# Documentation

You can generate documentation with [doxygen](http://www.doxygen.org). The example project includes a documentation build target to do this within Xcode.    For more details, see the [Documentation](https://github.com/epreston/PSTreeGraph/wiki/Documentation) page in this projects wiki.

## Contribute

If you'd like to contribute to PSTreeGraph, start by forking this repository on GitHub:

       http://github.com/epreston/PSTreeGraph

The best way to get your changes merged back into core is as follows:

1. Clone down your fork
2. Create a thoughtfully named topic branch to contain your change
3. Hack away
4. Add tests and make sure everything still passes
5. If you are adding new functionality, document it in the README
6. Do not change the version number, I will do that on my end
7. If necessary, rebase your commits into logical chunks, without errors
8. Push the branch up to GitHub
9. Send a pull request to the epreston/PSTreeGraph project.

Or better still, [donate] (http://epreston.github.com/PSTreeGraph/) via the [project website] (http://epreston.github.com/PSTreeGraph/).


# Copyright and License

Copyright 2012 Preston Software.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this work except in compliance with the License.
   You may obtain a copy of the License in the LICENSE file, or at:

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.




[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/epreston/pstreegraph/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

