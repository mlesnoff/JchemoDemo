This note provides some tips, for **Windows users**, on how to start with Julia when using the editor Visual Studio Code (VsCode).  

### **INSTALL VsCode**

#### **Download**

- https://code.visualstudio.com/Download

#### **Where is installed VsCode**

- By default, VsCode is installed at
*C:/Users/your_user_name/AppData/Local/Programs/Microsoft VS Code*


### **INSTALL Julia** 

The official installation procedure uses the `juliaup` installer

- https://julialang.org/install/

that can be directly downloaded [here](https://www.microsoft.com/store/apps/9NJNWW8PVKMN).

A manual download is also available [here](https://julialang.org/downloads/) but this is not the recommended installation procedure anymore.

#### **Where is installed Julia**

- By default, Julia is installed at (e.g. for release 1.11.5)  
*C:/Users/your_user_name/AppData/Local/Programs/Julia 1.11.5*

- Packages are installed at 
*C:/Users/your_user_name/.julia/packages*. 

- The pre-compiled packages are at
*C:/Users/your_user_name/.julia/compiled/v1.11*

#### **Link Julia and Vscode**

Before to be able to use Julia within VsCode, some configuration is needed

- Open VsCode

- Install the Julia extension 
    - Go to the 'Manage' icone (= **toothed wheel** at the bottom left of the screen)
    - Go to 'Extensions'
    - Search 'Julia' in the marketplace and install it   

- Connect VsCode and a given release of Julia 
    - 'Manage' icone ==> Settings ==> Commonly used ==> Extensions ==> Julia ==> Executable path
    - Copy the full path of the file *julia.exe* of the release that has to be used, 
        e.g.: *C:/Users/your_user_name/AppData/Local/Programs/Julia 1.11.5/bin/julia.exe*
    - If another release (e.g. 1.8.4) has to be used in future sessions, replace the new path in the same way, and re-run VsCode 

- Then a [REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) (= Julia command console) can be open 
    - 'Manage' icone ==> Command Palette ==> Start REPL 
        (or Alt+J Alt+O)

### **Julia REPL**

The REPL is a full-featured interactive command-line console. Basically, there are **two REPL modes** (in addition to the help one, reachable by typing `?` and a given function name in the REPL):

* The **command REPL**
```julia
julia>
```
* The **Pkg REPL** (see [here](https://docs.julialang.org/en/v1/stdlib/Pkg/))
```julia
(@v.1.11)  pkg> 
```

**Command REPL** is the usual mode for computations. **Pkg REPL** is used to manage packages and project-environments.

Typing `]` in the command REPL makes switch to the Pkg REPL, and the backslash makes return to the command REPL.

### **ENVIRONMENTS**

An **environment** (= list of the used packages and their versions) is defined 
by the following two files: ***Project.toml*** and ***Manifest.toml***.  
- File *Project.toml* defines the packages attached to the environment.
- File *Manifest.toml* manages the versions and dependencies of these packages.

To understand and know how to magage environments is very important to develop 
Julia projects in good ways. 
- At the installation of Julia, a default environment 
is created: the **global environment**. It is generally recommended to install 
only few packages in the global environment. 
- Instead, for each operational study of the user, it is recommanded to build a specific **project-environment** that will contain its own package dependencies (*Project.toml* and *Manifest.toml*).

**Note:** In any given environment, it is not safe and not recommanded to modify file *Manifest.toml* by hand. When a package is added to the environment using the Pkg REPL, *Manifest.toml* is automatically updated.

### **GLOBAL ENVIRONMENT**

#### **Where it is located** 
- The global environment (files *Project.toml* and *Manifest.toml*) of all 
the [*patch releases*](https://julialang.org/blog/2019/08/release-process/#minor_releases) 
of Julia (e.g. 1.11.0, 1.11.1, etc.) of a given [*minor version*](https://julialang.org/blog/2019/08/release-process/#minor_releases) of Julia (e.g. 1.11) is located (for the example of 1.11) at 
*C:/Users/your_user_name/.julia/environments/v1.11*

#### **Upgrade to a new minor version of Julia**

When upgrading to a new minor version (e.g. from 1.11 to 1.12), the new global environment (corresponding to 1.12) will be empty. Several ways can be used to build the new global environment from the previous one (corresponding to 1.11). The following example provides two simple (non exhaustive) ways.  

**Examples of how to upgrade the global environment from Julia 1.11.5 to 1.12.1**

- Install 1.12.2 (1.11.5 is already installed)
- Update the executable path in the settings of VsCode (as indicated in a previous section) and re-run VsCode
- A new directory 'v1.12' should be created under 
    *C:/Users/your_user_name/.julia/environments/*. If not, create it

Then:
- **First option (safer)**
    - Copy file *Project.toml* from 
        *C:/Users/your_user_name/.julia/environments/v1.11/* to 
        *C:/Users/your_user_name/.julia/environments/v1.12/*
    - Then type in Pkg REPL: 
        ```julia 
        (@v1.12) pkg> instantiate
        ```
    - This creates file *Manifest.toml* corresponding to the contents of *Project.toml* and resolves automatically eventual compatibility constraints within the new Julia version
- **Second option**
    - Copy both files *Project.toml* and *Manifest.toml* from *C:/Users/your_user_name/.julia/environments/v1.11/* to *C:/Users/your_user_name/.julia/environments/v1.12/*
    - This will define for 1.12 the same environment as under 1.11 (exactly the same package versions). Nevertheless, this does not protect against eventual compatibility problems with the use of 1.12

Other information are given [here](https://docs.julialang.org/en/v1/manual/faq/#How-can-I-transfer-the-list-of-installed-packages-after-updating-my-version-of-Julia?).

### **PROJECT ENVIRONMENTS**

In a simplified way, a **project** is a directory and, if this directory contains files *Project.toml* and *Manifest.toml*, this is a **project-environment**, 
i.e. a project with its own independant environment (installed packages).

It is recommended to create such a project-environment for each new operational work. This allows to limitate the number of installed package in the specific environment (or in the global environment) and therefore the risk of eventual conflicts between packages versions.  

#### **How to open a project already existing in a given path** 

- In VsCode, menu 'File' ==> 'Open Folder' or 'Open Recent' 
- Select the directory of the project
- ==> VsCode locates in the corresponding path. This can be checked by typing in the command REPL:
```julia 
    julia> pwd()
```
- If files *Project.toml* and *Manifest.toml* are present in the directory, the environment of the project is loaded (if the dependent packages of this environment have never been installed, use the command `instantiate` as explained in the next section)
- If they are not present, the folder is a simple project (not a project-environment) and VsCode loads the global environment 

#### **How to install an external project-environment**

As an example, this section shows how to install the external project-environment [JchemoDemo](https://github.com/mlesnoff/JchemoDemo).

- Go to this [address](https://github.com/mlesnoff/JchemoDemo)
- Green button 'Code' ==> Download ZIP
- Create a working directory on your PC and unzip the zip file. A new unzipped directory is created, in this example *JchemoDemo-main*. The name of this new directory can be modified at will, for instance here to *JchemoDemo*; it will be the name of the project
- In VsCode, menu 'File' ==> Open Folder 
- Select the directory of the project *JchemoDemo*
- ==> VsCode locates in the corresponding path
- Check the dependent packages by typing in Pkg REPL:
```julia 
    (JchemoDemo) pkg> status
```

This will print (in the REPL) the list of the dependent packages. At this step, the dependent packages **are not installed yet** and therefore cannot be used. To install the dependent packages, **a web connection is needed**. The installation is done by using function `instantiate`:
- Type in Pkg REPL: 
```julia 
    (JchemoDemo) pkg> instantiate
```
This step can stay some times (**do not interrupt Julia before the end**). At its end, project *JchemoDemo* and its environment can be used.   

The `instantiate` step needs only to be done **at the first installation**. For the next working sessions, how to simply open the existing project-environment is described in the previous section.

#### **How to create a project-environment from scratch**

An easy way is the following (many other ways are possible)

- Let us assume that Julia 1.11.5 is used
- Create an empty directory that will receive the given project, for instance here named 'StudyTrees', then *D:/Users/Tmp/StudyTrees/* 
- In VsCode, menu 'File' ==> Open Folder
- Select the directory *D:/Users/Tmp/StudyTrees/*
- ==> VsCode locates in the corresponding path
- Type in the Pkg REPL:
```julia 
    (@v1.8) pkg> activate .
```

(the **dot** at the end of the above command means that VsCode will load the project of where VsCode locates; if the dot is removed after command `activate`, the command loads the global environment)

- Install one package (any package can be chosen), for instance package *StatsBase.jl*, from the official Julia packages repository 
    - In the Pkg REPL, type
    ```julia 
        (StudyTrees) pkg> add StatsBase
    ```
    - This installs *StatsBase.jl* in the environment, and creates the corresponding files *Project.toml* and *Manifest.toml* in the *StudyTree* directory. The project-environment *StudyTrees* is now created
- To check the installed package in the project-environment *StudyTrees*, type in Pkg REPL:  
```julia 
    (StudyTrees) pkg> status
```

#### **General commands to activate an environment** 

Any project-environment can be loaded using command `activate` in the Pkg REPL. For instance, let us assume that project-environment *StudyTrees* already exists at location *D:/Users/Tmp/StudyTrees/*. Then

- From any path location, *StudyTrees* can be loaded by typing
    in Pkg REPL:
```julia 
    (@v.1.11) pkg> activate "D:/Users/Tmp/StudyTrees"
```

- or locate directly in the directory of project *StudyTrees* and 
    type in Pkg REPL:
```julia 
    (@v.1.11) pkg> activate .
```

To locate in *StudyTrees* directory, type in command REPL
```julia 
    julia> path = "D:/Users/Tmp/StudyTrees/"
    julia> cd(path)
```

or locate above the directory of project *StudyTrees* and type in Pkg REPL:
```julia 
    (@v.1.11) pkg> activate StudyTrees
```

To locate above *StyTrees* directory, type in command REPL
```julia 
    julia> path = "D:/Users/Tmp/"
    julia> cd(path)
```

An easy way to **switch from a local environment (e.g. *StudyTrees*) to the global environment** is as follows 
- Assume that VsCode is located at *D:/Users/Tmp/StudyTrees/*. In the Pkg REPL, typing
    - `activate` loads the global environment
    - `activate .` comes back to the local enviroment *StudyTrees*

See also (not exhaustive)
- [here](https://pkgdocs.julialang.org/v1/) , [here](https://pkgdocs.julialang.org/v1/getting-started/),  [here](https://pkgdocs.julialang.org/v1/environments/), [here](https://towardsdatascience.com/how-to-setup-project-environments-in-julia-ec8ae73afe9c) 

### **FEW USEFUL COMMANDS**

#### **Command REPL**

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


#### **Pkg REPL**

In a project environmenet
- `instantiate` regenerates Manifest.toml from the existing Project.toml
- `status` shows the installed packages
- `update` updates the packages
- `gc` cleans up any packages that aren’t used by any environment

