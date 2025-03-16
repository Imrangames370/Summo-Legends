extends Node

"Only bugs to fix instantly are those that are imminently harmful to gameplay. Ones which have a minimal effect on
gameplay aren't a priority. If the game basically runs the same you are better off finishing the game than wasting time
fixing every tiny bug currently.

ball sometimes jumps forward esescially when using wasd for a while and then using click movement. sometimes when swapping
between wasd and click movement it goes to the opposite side before going to where i clicked"

#3. remove small dot in middle of camera.

#camera keys are bugged and dont swap cameras. also need some movement to the camera mid game, maybe shaking when a player gets
# eleminated or something idk.
# espesciall on big platfors i need the camera to zoom in so change its fov if theres no players on the edges or anywhere nearby
# like on a massive map if only two players are alive the camera only has to be zoomed out enough to show those 2 players.

#4. no default color for platform bc whenever i tried to have a default color for the platform it made it so the color change didn't work.
#having two material ovverrides is the core problem but material override seems to be the only way to set and change color.
#there are other ways to assign colors. maybe i could set a node color or whatever to the defeault platforms. Then set that node color to
#not visible when it is called in change color. 

# 5. LATER BUG
#still gotta fix the whole platform thing setting for rotation like yk there is a setting thats supposed to make everything 
#rotate if u have it enabled. also i wanna make that on by default yk.

#6. credit the fire guy ball tamminen Flaming orb which i used for https://sketchfab.com/3d-models/flaming-orb-d7f8cda1e8ae4e458cd674bc18db672c
#its the energy orb. just make a small credits tab.
#credit them with this preferably
#"Flaming orb" (https://skfb.ly/oCnFp) by tamminen is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).

#7. energy balls dont collide correctly if u hit them diagonally. this is infrequent but if u keep trying to trigger the bug itll happen.
#basically raycast doesnt detect it properly from certain angles. raycast is a crude method but the only one i have been able to get to work.
#would like to do a static body energy orb collission detection via player rigid body and these 2 collision shapes, and whenever they collide
# the energy increase and orb delete triggers.

#8using MSAA 3D on 4X which makes edges smoother. makes spheres look much better. this is in project setting under anti aliasing. 
#make it so anti aliasing can be turned off. Or reduced. Espescially  for if u do a mobile version. 

#9 also in project settings consider setting shadows to be higher quality. there are different mobile and pc shadow qualities. make it so ppl 
#can configure their shadow quality
#shadow quality is set on highest setting on pc by default. make this configurable so ppl can turn them off or set it at lowest setting.


#11 platform marketplace and buy options and sell options need to be reset after every match otherwise when u click rematch
#its gonna error or not work properly.
#also must be reset after a platform gets deleted via manual player destroy or auto stage deathmatch destroy
