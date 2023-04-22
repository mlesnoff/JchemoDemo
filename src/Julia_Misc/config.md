This script provides some tips about the **installation of Julia and how to start with the software**. It is orientated for Windows users. 

### **INSTALL Julia** 

#### **Download**

- Current stable release: https://julialang.org/downloads/
- For older releases: https://julialang.org/downloads/oldreleases/

During the installation, there is no mandatory need to put a path in the PATH Variable (by default, don't put).

#### **Where is installed Julia**

- By default, Julia is installed at (e.g. for release 1.8.3)  
*C:\Users\your_user_name\AppData\Local\Programs\Julia 1.8.3*

- Packages are installed at 
*C:\Users\your_user_name\.julia\packages*. 

- The pre-compiled packages are at
*C:\Users\your_user_name\.julia\compiled\v1.8*

### **INSTALL Visual Studio Code (VsCode)**

#### **Download**

- https://code.visualstudio.com/Download

#### **Where is installed VsCode**

- By default, VsCode is installed at
*C:\Users\your_user_name\AppData\Local\Programs\Microsoft VS Code*

#### **Configuration for Julia**

Before to be able to use Julia within VsCode, some configuration is needed.

- Open VsCode

- Install the Julia extension 
    - Go to the icone 'Manage' (toothed wheel at the bottom left of the screen)
    - Go to 'Extensions'
    - Search 'Julia' in the marketplace and install it   

- Connect VsCode and a given release of Julia 
    - Icone 'Manage' ==> Settings ==> Commonly used ==> Extensions ==> Julia ==> Executable path
    - Copy the full path of the file *julia.exe* of the release that has to be used, 
        e.g.: *C:\Users\your_user_name\AppData\Local\Programs\Julia 1.8.3\bin\julia.exe*
    - If another release (e.g. 1.8.4) has to be used in future sessions, replace the new path in the same way, and re-run VsCode 

- Then a REPL (= Julia command console) can be open 
    - Icone 'Manage' ==> Command Palette ==> Start REPL 
        (or Alt+J Alt+O)

### **CONSOLE REPL**

The **REPL** can be used in two modes:
* The **command REPL**
```julia
julia>
```
* The **Pkg REPL**
```julia
pkg> 
```

**Command REPL** is the usual mode for computations. **Pkg REPL** is used to manage packages and project environments.

Typing `]` in the command REPL makes switch to the Pkg REPL, and the backslash makes return to the command REPL.

### **ENVIRONMENTS**

An environment (= list of the used packages and their versions) is defined by files ***Project.toml*** and ***Manifest.toml***.  File *Project.toml* defines the packages attached to the environment and file *Manifest.toml* manages the versions and dependencies of these packages.

To understand and know how to magage environments is very important to develop Julia projects in good ways.
At the installation of Julia, a default environment is created: the **global environment**. It is generally recommended to install only few packages in the global environment. Instead, for each operational study that is developed, it is recommanded to build a specific **project environment** in which its own package dependencies will be defined (*Project.toml* and *Manifest.toml*).

**Note:** In any given environment, it is not safe and not recommanded to modify file *Manifest.toml* by hand. When a package is added to the environment, *Manifest.toml* is automatically updated.

### **GLOBAL Julia ENVIRONMENT**

#### **Where it is located** 
- The global environment (files *Project.toml* and *Manifest.toml*) of all the [*patch releases*](https://julialang.org/blog/2019/08/release-process/#minor_releases) of Julia (e.g. 1.8.0, 1.8.1, etc.) of a given [*minor version*](https://julialang.org/blog/2019/08/release-process/#minor_releases) of Julia (e.g. 1.8) is located (for the example of 1.8) at 
*C:\Users\your_user_name\.julia\environments\v1.8*

#### **Upgrade to a new minor version of Julia**

When upgrading to a new minor version (e.g. from 1.7 to 1.8), the new global environment (corresponding to 1.8) will be empty. Several ways can be used to build the new global environment from the previous one (corresponding to 1.7). The following example provides two simple (non exhaustive) ways.  

**Examples of how to upgrade the global environment from Julia 1.7.3 to 1.8.1**

- Install 1.8.1 (1.7.3 is already installed)
- Update the executable path in the settings of VsCode (as indicated in a previous section) 
    and re-run VsCode
- A new directory 'v1.8' should be created under 
    *C:/Users/your_user_name/.julia/environments/*. If not, create it
- Then, **first option (safer)**
    - Copy file *Project.toml* from 
        *C:/Users/your_user_name/.julia/environments/v1.7/* to 
        *C:/Users/your_user_name/.julia/environments/v1.8/*
    - Type in Pkg REPL: 
        ```julia 
        (@v1.8) pkg> instantiate
        ```
    - This creates file *Manifest.toml* corresponding to 
    the contents of *Project.toml* and resolves automatically eventual compatibility constraints within the new Julia version
- **Second option**
    - Copy both files *Project.toml* and *Manifest.toml* from 
    *C:/Users/your_user_name/.julia/environments/v1.7/* to 
    *C:/Users/your_user_name/.julia/environments/v1.8/*
    - This will define for 1.8 the same environment as under 1.7 (exactly the same package versions). Nevertheless, this does not protect against eventual compatibility problems with the use of 1.8

Other information are given [here](https://docs.julialang.org/en/v1/manual/faq/#How-can-I-transfer-the-list-of-installed-packages-after-updating-my-version-of-Julia?).

### **PROJECT ENVIRONMENTS**

In a simplified way, a project is a directory and, if this directory contains files *Project.toml* and *Manifest.toml*, this is **project environment**, i.e. a project with its own independant environment (installed packages).

It is recommended to create such a project environment for each new operational work. This allows to limitate the number of installed package (in the specific environment) and therefore the risk of evnetual conflicts between packages versions.  

#### **Open an existing project** 

- In VsCode, menu 'File' ==> 'Open Folder' or 'Open Recent' 
- Select the directory of the project
- ==> VsCode locates in the corresponding path. This can be checked; type in the command REPL:
```julia 
    julia> pwd()
```
- If *Project.toml* and *Manifest.toml* are present, the project environment is loaded
- If the folder is not a project environment (files *Project.toml* and *Manifest.toml* not present), this is a simple project and VsCode loads the global environment 

#### **Create a project environment from scratch**

An easy way is the following (many other are possible).

- Create an empty directory that will receive the project (e.g. named 'StudyTrees'), for instance *D:/Users/Tmp/StudyTrees/* 
- In VsCode, menu 'File' ==> Open Folder
- Select the directory *D:/Users/Tmp/StudyTrees/*
- ==> VsCode locates in the corresponding path
- Type in the Pkg REPL:
```julia 
    pkg> activate .
```

(the dot at the end of the above command means that VsCode will load the project of where VsCode locates; if the dot is removed, VsCode loads the global environment)
- Install one package (any package can be chosen), for instance package *StatsBase.jl*, from the official Julia pckages repository 
    - In the Pkg REPL, type
    ```julia 
        pkg> add StatsBase
    ```
    - This installs *StatsBase.jl* in the environment, and creates the corresponding files *Project.toml* and *Manifest.toml* in the 'StudyTree' directory. The project environment "StudyTrees" is now created
- To check the installed package in the project environment 'StudyTrees', type in Pkg REPL:  
```julia 
    pkg> status
```

#### **Activate an environment** 

Any project environment can be loaded using command `activate` in the REPL management mode (`]`). For instance, for project "StudyTrees" already existing at location "D:/Users/Tmp/StudyTrees/"   
- From any path location 
    -  In the management mode (`]`), run command `activate "D:/Users/Tmp/StudyTrees"`
- or locate directly in the directory of the project and, in the management mode  (`]`), run command `activate .`
    - To locate in the repository, run in REPL
        - `path = "D:/Users/Tmp/StudyTrees/"`
        - `cd(path)`
- or locate above the project repertory and, in the management mode  (`]`), run command `activate StudyTrees` 
    - To locate above the repository, run in REPL
        - `path = "D:/Users/Tmp/"`
        - `cd(path)`

**An easy way** to switch from a local environment (e.g. "StudyTrees") to the global environment is as follows 
- Assume that VsCode is located at *D:/Users/Tmp/StudyTrees/*. In the management mode (`]`), run
    - `activate` to load the global environment
    - `activate .` to come back to the local enviroment "StudyTrees"

See:
- https://pkgdocs.julialang.org/v1/
- https://pkgdocs.julialang.org/v1/getting-started/
- https://pkgdocs.julialang.org/v1/environments/
- https://towardsdatascience.com/how-to-setup-project-environments-in-julia-ec8ae73afe9c 



### **6. FEW COMMANDS**

#### **REPL**

- `versioninfo()`
- `VERSION`
- `tempdir()`   # Location of the default temporary directory 
- `pwd()`
- `readdir()`
- `cd()`        # Locate in default
- `cd("..")`    # Locate above 
- `cd("./StudyTrees/")`
- `mkdir("dd")` # create sub-directory "dd" under the active path  
- `rm("dd")`    # remove "dd"


#### **Management mode (`]`)**

In a project environmenet
- `instantiate` regenerates Manifest.toml from the existing Project.toml
- `status` shows the installed packages
- `gc` cleans up any packages that aren’t used by any environment

