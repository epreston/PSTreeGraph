
# PSTreeGraph

PSTreeGraph is a treegraph view control implementation for Cocoa Touch.

This is a port of the sample code from Max OS X to iOS (iPad). 
WWDC 2010 Session 141, “Crafting Custom Cocoa Views”

![](http://farm7.static.flickr.com/6193/6055022105_ab831b2d8e.jpg)


# Example Project

There is an iPad example application to demonstrate the features of PSTreeGraph.


# Status

PSTreeGraph should be considered an viable solution for displaying single parent tree data in an interactive hierarchy.

This project follows the [SemVer](http://semver.org/) standard. The API may change in backwards-incompatible ways before the 1.0 release.

The goal of PSTreeGraph is to build a high-quality UI control designed specifically for the iPad.  The inspiration / structure comes from WWDC 2010 Session 141, “Crafting Custom Cocoa Views”, an extremely valuable and informative presentation that has proven to be applicable (see this project) to other platforms.


# Known Improvements

See [Milestones](https://github.com/epreston/PSTreeGraph/issues/milestones?with_issues=no).

There are many places where PSTreeGraph could be improved:

* Add Cached NIB Support.  The node views are loaded from a nib file that defines their layout. In IOS 4 and above, nib caching was introduced for things like UITableView cells. This control would benefit from this feature.

* Use GCD to load model data asyncronously.  This control uses a simple protocol implemented by each node in the data model so the control can walk the tree. This can be loaded asynchronously to avoid blocking the main thread when displaying large graphs.

* Cache the bezier path used to render lines in each subtree.  The bezier path used to render the lines between each node in the graph can be cached to improve performance.

* Use CATiledLayer to support much larger graphs.  Investigate using a CATiledLayer to further reduce drawing and memory usage, support scaling, etc. This feature will make it possible support graphs of unlimited size and scale. Rendering time and resource usage would be constant regardless of the number of nodes in the graph.


# Documentation

You can generate documentation with [doxygen](http://www.doxygen.org). The example project includes a documentation build target.

Documentation is a work in progress.


# Copyright and License

Copyright 2010 Preston Software.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this work except in compliance with the License.
   You may obtain a copy of the License in the LICENSE file, or at:

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


