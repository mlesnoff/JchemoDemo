using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
CairoMakie.activate!()  

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)
  
```julia
X = dat.X 
n = nro(X)

```julia term = true
@head X

```julia
wl = names(X)
wl_num = parse.(Float64, wl)

```julia
## Six of the samples of the dataset contain 
## added alcohol  (= 25, 26, and 36-39)
plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Octane data").f

```julia
## Model fitting
fm = pcasvd(X; nlv = 6) ; 
## For robust PCA:
#fm = pcasph(X; nlv = 6) ;  
pnames(fm)

```julia
## Summary of the fitted model
res = summary(fm, X) ;
pnames(res)

```julia
## % Variance explained
z = res.explvarx

```julia
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

```julia
## Individuals' contributions to scores
z = res.contr_ind

```julia
i = 1
scatter(z[:, i];
    axis = (xlabel = "Observation", ylabel = "Contribution", 
        title = string("PC", i)))

```julia
## Same:
plotxy(1:n, z[:, i];
    xlabel = "Observation", ylabel = "Contribution", 
    title = string("PC", i)).f

```julia
## Variables' contributions
z = res.contr_var 

```julia
i = 1
scatter(z[:, i], z[:, i + 1])

```julia
## Correlation circle
z = res.cor_circle

```julia
i = 1
plotxy(z[:, i:(i + 1)]; resolution = (400, 400),
    circle = true, zeros = true,
    xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f

