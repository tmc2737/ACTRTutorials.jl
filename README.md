# ACTRTutorials.jl

ACTRTutorials.jl is a collection of tutorials for developing ACT-R models within a likelihood framework.  

# Key Features

1. Tutorials are written in interactive Jupyter notebooks with integrated code and annotation in HMTL and LaTeX markdown. 

2. The collection of model tutorials spans declarative memory, procedural memory, visual search, and ranges in difficulty from simple to advanced. 

3. The collection includes background tutorials on mathematical notation, Bayesian inference, MCMC sampling, the Julia programming language, supporting software libraries and more.

4. Additional tutorials cover approximate likelihood methods and Bayesian adaptive design optimization.

# Installation

Please follow the steps below to install the tutorial.

## 1. Download Julia

Install the latest stable version of Julia from the following download page:

    https://julialang.org/downloads/

## 2. Launch Julia

Launch Julia. Most operating systems will create a shortcut in your programs or apps folder.

## 3. Open Pluto

In the REPL (command line), type the following:

    using Pluto

As shown below, if Pluto has not been installed, you will need to type y to install once prompted.

```julia
julia> using Pluto
 │ Package Pluto not found, but a package named Pluto is available from a registry. 
 │ Install package?
 │   (@v1.7) pkg> add Pluto 
 └ (y/n) [y]: 
```
## 4. Launch the notebook

Once Pluto is installed and loaded, type the following to launch the notebook in your browser:

    Pluto.run()

## 5. Select a Tutorial

The main page for Pluto features a text field labeled `Open from file:` where you can type the directory in which the tutorial is location. Once you have reached the main folder of the tutorial, navigate to `/Table_Of_Contents/Table_Of_Contents.jl`. and press enter or click `open`. This will open a table of contents with hyperlinks to specific tutorials.

 # Bug Reporting

If you encounter a bug or a problem during installation, please report the following information when applicable:

1. A brief discription of the problem.
2. A description of the expected behavior.
3. An error message if available.
4. The version of your operating system, Julia, and package version information.
Package version information can be found in the package mode with the command: 
     
     `] status`
     
5. A minimal reproducable example if possible.

DISTRIBUTION A. Cleared for public release, distribution unlimited
(AFRL-2022-3018)