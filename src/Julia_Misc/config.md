This script provides some tips about the environment of Julia (orientated for Windows users). 

### **1. INSTALL Julia** 

#### **Download**

- Current stable release: https://julialang.org/downloads/
- For older releases: https://julialang.org/downloads/oldreleases/

#### **Locations**

- By default, Julia is installed at (e.g. for release 1.8.3)  
*C:\Users\your_user_name\AppData\Local\Programs\Julia 1.8.3*

- During the installation, no need to put a path in the PATH Variable

- Packages are installed at 
"C:\Users\your_user_name\.julia\packages". Note: In this directory, to remove the directory of the corresponding 
package (only if Pkg.rm is not enough) may help when there is a compilation problem 
when "using ..." 

- The pre-compiled packages are at
*"*C:\Users\your_user_name\.julia\compiled\v1.8*"*

### **2. INSTALL VSCode**

#### **Download**

- https://code.visualstudio.com/Download

#### **Location**

- By default, VsCode is installed at
*C:\Users\your_user_name\AppData\Local\Programs\Microsoft VS Code*

#### **Configuration**

- Open VsCode

- Install the Julia extension within VsCode 
    - Go to the icone "Manage" (wheel at the down and left of the screen)
    - Go to "Extensions"
    - Search "Julia" in the marketplace and install it   

- Connect VsCode and a given release of Julia 
    - "Manage" ==> Settings ==> Commonly used ==> Extensions ==> Julia ==> Executable path
    - Copy the full path of the location of the file "julia.exe" of the release that has to be used, 
        e.g.: *C:\Users\your_user_name\AppData\Local\Programs\Julia 1.8.3\bin\julia.exe*
    - If another release has to be used in future sessions, replace this path in the same way, and re-run VsCode 

- Then a REPL (= Julia command console) can be open 
    - "Manage" ==> Command Palette ==> Start REPL 
        (or Alt+J Alt+O)

### **3. GLOBAL Julia ENVIRONMENT**

An environement (list of the used packages and versions) is defined by files "Manifest.toml" and "Project.toml". Note: Do not modify Manifest.toml by hand.

#### **Location** 
- The global environment (Manifest.toml and Project.toml) of a given "minor version" of Julia (e.g. 1.8) is located at 
"C:\Users\your_user_name\.julia\environments\v1.8\"
- The global environment is the same within all the releases of a given minor version (e.g. 1.8.1, 1.8.2, etc. within the minor version 1.8) 

### **4. UPGRADE TO A NEW VERSION OF Julia**

Upgrade from a minor version to another minor version (e.g. from v1.7 to v1.8)
- See explanations here:
https://docs.julialang.org/en/v1/manual/faq/#How-can-I-transfer-the-list-of-installed-packages-after-updating-my-version-of-Julia?

#### **Example: Upgrade from 1.8.3 to 1.9.1**

- Install the new release 1.9.1
- Update the path in the setting of VsCode (as indicated in Section 1) 
    and re-run VsCode
- A new directory "v1.9" should be created at 
    "C:\Users\your_user_name\.julia\environments\v1.9\" 
    (if not, create it)
- First option (safer)
    - Copy file "Project.toml" from 
        *C:\Users\your_user_name\.julia\environments\v1.8\* to 
        *C:\Users\your_user_name\.julia\environments\v1.9\*
    - In the VsCode REPL, use the "package management mode" 
    (by typing `]`) and type command `instantiate`
    - This creates the file "Manifest.toml" corresponding to 
    the contents of "Project.toml" and resolves automatically eventual compatibility constraints
- Second option
    - Copy files "Project.toml" and "Manifest.toml" from 
    *C:\Users\your_user_name\.julia\environments\v1.8\* to 
    *C:\Users\your_user_name\.julia\environments\v1.9\*
    - This will correspond to the same environment as under v1.8 (exactly the same package versions) but do not protect against compatibility problems with the use of v1.9

### **5. PROJECT ENVIRONMENTS WITH VsCode**

See:
- https://pkgdocs.julialang.org/v1/
- https://towardsdatascience.com/how-to-setup-project-environments-in-julia-ec8ae73afe9c 

In a simplified view, a project is a directory and, if this directory contains files Project.toml and Manifest.toml, the project has its own independant environment (project environment).

#### **Open an existing project** 

- Menu "File" ==> "Open Folder" 
- Select the directory of the project
- ==> VsCode locates in the corresponding path
- If Project.toml and Manifest.toml are present, the project environment is loaded
- If the folder is not a project environment, VsCode loads the global environment 

#### **Create a project environment from scratch**

An easy way is the following (many other ways are possible).

- Create an empty directory that will receive the project (e.g. "Nn"), for instance *D:/Users/Tmp/Nn/* 
- Menu "File" ==> "Open Folder"
- Select the directory *D:/Users/Tmp/Nn/*
- ==> VsCode locates in the corresponding path
- Install one (any) package, for instance package "StatsBse.jl" from the official Julia pckages repository 
    - In the REPL, use the management mode (`]`) and 
        type command `add StatsBase`
    - This instals the package in the environment, and creates files Project.toml and Manifest.toml in the directory
    - The project environment "Nn" is now created
- Using the management mode (`]`), command `status` shows the installed packages in "Nn"  

#### **Activate an environment** 

Any project environment can be loaded using command `activate` in the management mode (`]`). For instance for project "Nn" already existing at location "D:/Users/Tmp/Nn/"   
- From any location 
    -  In the management mode (`]`) run command `activate "D:/Users/Tmp/Nn"`
- or locate in the project repertory and run command `activate .` in the management mode  (`]`). To locate in the repository, run in REPL
    - `path = "D:/Users/Tmp/Nn/"`
    - `cd(path)`
- or locate above the project repertory and run command `activate Nn` in the management mode  (`]`). To locate above the repository, run in REPL
    - `path = "D:/Users/Tmp/"`
    - `cd(path)`

An easy way to switch from a local environment, e.g. "Nn", to the global environment is as follows. 
Assume that VsCode is located to *D:/Users/Tmp/Nn/*. In the management mode (`]`)
- `activate` : Load the global environment
- `activate .` : Coming back to the local enviroment

### **6. FEW COMMANDS**

#### **REPL**

- `versioninfo()`
- `VERSION`
- `tempdir()` 
- `pwd()`
- `readdir()`
- `cd("..")`
- `cd("./Nn/")`

#### **Management mode (`]`)**

In a project environmenet
- `instantiate` : regenerate Manifest.toml from the existing Project.toml
- `status` : shows the installed packages
- `gc` : clean up any packages that aren’t used by any environment

