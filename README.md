# Better Slicer

Better Slicer is a handy Aseprite script for creating slices in large number with ease

<br />
For more information check out the Itch page: https://ngndang.itch.io/better-slicer-for-aseprite

<br />
<br />

**Changelog:**

+ v1.0: Initial release


## Main features ##
+ Creating Slices Automatically 
+ Creating a Grid of slices based on Grid size
+ Creating a Grid of slices based on the number of columns and rows
 
 and also:
+ Naming and coloring slices 
+ Works alongside [**SLICE MANAGER**](https://github.com/ngndang/Slice-Manager) - another script I made for managing large amounts of slices. You can rename, recolor, delete slices etc... all in bulk

## How to use ##

For guide to how to install a script check our this [Post](https://community.aseprite.org/t/aseprite-scripts-collection/3599) on the community

Open the script by choosing: File > Scripts > Better Slicer

<br />

There are three modes:

<br />

============ **Automatic mode** ============ 

**Step 1:** Just select the mode, hit *Slice*, and let my script do the rest!

**Step 2:** Admire your artwork

![tut_slice_auto](https://user-images.githubusercontent.com/78392599/139862305-4f9eeb4b-9e9a-4432-ad48-4aaf705672b6.gif)

<br />

**NOTE:**
+ The script (currently) will have to delete all current slices on the canvas
+ It will only create slices for your active/selected layer and frame.
+ Make sure your sprites are not connected/next to each other, it will select the whole bunch 

>Again, I'm still working on improving this feature for the future, so stay tuned ^^

<br />

============ **Grid by Cell Size mode** ============

1. Select an rectangular area with selection tool

2. Choose a size for the slice

3. Hit *Slice*

![tut_slice_by_size](https://user-images.githubusercontent.com/78392599/139844600-0303818f-37f4-4d53-9226-2a3547e3fb20.gif)

<br />
============ **Grid by Count mode** ============

1. Select an rectangular area with selection tool

2. Put in the number of slices in a row and in a column

3. Hit *Slice*

![tut_slice_by_count](https://user-images.githubusercontent.com/78392599/139844969-f1b197d5-7851-4349-9186-1373a5d99c99.gif)

**Other information**
+ The naming format is: name_number, where number is the order of the sprite on the grid
+ Every operation is undo-able

