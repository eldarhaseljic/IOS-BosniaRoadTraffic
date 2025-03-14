#!/bin/zsh
#
# Created by Eldar Haseljic on 3/10/23.
#
# This script is used for
# - checking all unreferenced files
# - checking all empty and unreferenced directories
# - checking all unused images
# - checking all unused colors
#
# How to use the script:
# To just check unreferenced files in project
#   Execute ./filesChecker.sh
# in terminal 
#
# To check and remove unreferenced files in project
#   Execute
#       ./filesChecker.sh -r true
#   or
#       ./filesChecker.sh -remove true
# in terminal

declare -a projects=("{pathToProjectfolder}")
declare -a projectsWithImages=("{pathToProjectfolder}")
declare -a projectsWithColors=("{pathToProjectfolder}")
declare -a mainProjectLocation=("{pathToProjectfolder}.xcodeproj/project.pbxproj")
declare -a fileSystemSynchronizedGroups=("{pathToProjectfolder}")
remove="false"

# Check if the remove flag is set
if [[ $1 =~ ^(-r|--remove) ]]; then
    remove="$2"
fi
echo "The flag for removing is set to $remove"

# Function to check if a file is in a synchronized group
is_in_synchronized_group() {
    local dir="$1"
    for group in "${fileSystemSynchronizedGroups[@]}"; do
        if [[ "$dir" == $group* ]]; then
            return 0  # True
        fi
    done
    return 1  # False
}

# Loop through all files and see which are not referenced
for project in "${projects[@]}"; do
    project_name=$(basename "$project")
    echo -e "\nChecking for not referenced files in $project_name"
    for file in "$project"/**/*.*; do
        echo -e "\e[32m Checking file $file \e[0m";
        # Skip files in synchronized groups
        if is_in_synchronized_group "$file"; then
            echo -e "\e[35m $file is in a synchronized gruop \e[0m";
        elif [[ "$file" != *.(xcassets|pbxproj|xcworkspace|xcworkspacedata|xcsettings|resolved|xcscheme|xcuserdatad|plist|strings|bazel|bzl)* ]] && ! grep -q "$(basename $file)" "$mainProjectLocation"; then
            if [[ "$remove" == true ]]; then
                rm -rf "$file"
                echo -e "\e[31m $(basename "$file") was not referenced and it is removed \e[0m";
            else
                echo -e "\e[33m $(basename "$file") is not referenced \e[0m";
            fi
        else
           :
        fi
    done
    echo "Finished checking not referenced files for $project_name"
done

# Loop through all directories and see which are empty and not referenced
for project in "${projects[@]}"; do
    project_name=$(basename "$project")
    echo -e "\nChecking for empty and not referenced directories in $project_name"
    for dir in "$project"*/**/; do
        if [[ "$dir" != *.(xcassets|xcodeproj)* ]] then
            echo -e "\e[32m Checking directory $dir \e[0m";
            # Check if directory is synchronized
            if is_in_synchronized_group "$dir"; then
                echo -e "\e[35m $dir is synchronized folder \e[0m";
            # Check if directory is referenced
            elif ! grep -q "$(basename $dir)" "$mainProjectLocation"; then
                if [[ "$remove" == true ]] then
                    rm -rf $dir;
                    echo -e "\e[31m $(basename $dir) was not referenced and it is removed \e[0m";
                else
                    echo -e "\e[33m $(basename $dir) is not referenced \e[0m";
                fi
            # Check if directory is empty
            elif [ -d "$dir" ] && [ ! "$(ls -A $dir)" ]; then
                if [[ "$remove" == true ]] then
                    rm -rf $dir;
                    echo -e "\e[31m $(basename $dir) was empty and it is removed \e[0m";
                else
                    echo -e "\e[33m $(basename $dir) is empty \e[0m";
                fi
            else
                :
            fi
        fi
    done
    echo "Finished checking empty and not referenced directories for $project_name"
done

# Since colors are stored in xcassets they are not visible in xcodeproj
# Loop through all colors and see which are not used
for project in "${projectsWithColors[@]}"; do
    project_name=$(basename "$project")
    echo -e "\nChecking for not used colors in $project_name"
    for color in "$project"*/**/*.colorset; do
        echo -e "\e[32m Checking color $color \e[0m"
        # Check if the color is used anywhere
        if ! grep -q "$(basename -s .${color##*.} $color)" "$project"*/**/*.(swift|xib|storyboard); then
            if [[ "$remove" == true ]] then
                rm -rf $color/*;
                rm -rf $color;
                echo -e "\e[31m $(basename $color) was not used and it is removed \e[0m";
            else
                echo -e "\e[33m $(basename $color) is not used \e[0m";
            fi
        fi
    done
    echo "Finished checking not used colors in $project_name"
done

# Since images are stored in xcassets they are not visible in xcodeproj
# Loop through all images and see which are not used
for project in "${projectsWithImages[@]}"; do
    project_name=$(basename "$project")
    echo -e "\nChecking for not used images in $project_name"
    for image in "$project"*/**/*.imageset; do
        echo -e "\e[32m Checking image $image \e[0m"
        # Check if the image is used anywhere
        if [[ "$image" != *.complicationset* ]] && ! grep -q "$(basename -s .${image##*.} $image)" "$project"*/**/*.(swift|xib|storyboard) && ! grep -q "$(basename -s .${image##*.} $image)" "../Application/GenesisApp/UnitTests"*/**/*.swift && ! grep -q "$(basename -s .${image##*.} $image)" "../Domain"*/**/*.(swift|xib|storyboard); then
            if [[ "$remove" == true ]] then
                rm -rf $image/*;
                rm -rf $image;
                echo -e "\e[31m $(basename $image) was not used and it is removed \e[0m";
            else
                echo -e "\e[33m $(basename $image) is not used \e[0m";
            fi
        fi
    done
    echo "Finished checking not used images in $project_name"
done
