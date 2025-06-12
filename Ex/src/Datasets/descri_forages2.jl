
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y
@head Y


wlst = names(X) 
wl = parse.(Int, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


typ = Y.typ
tab(typ)


test = Y.test  # training/test (0/1) observations
tab(test)
freqtable(Y.typ, test)


namy = names(Y)[1:2]
summ(Y[:, namy]).res


summ(Y[:, namy], test)


j = 2
nam = namy[2]
y = Y[:, nam]
s = test .== 0
ytrain = y[s] 
ytest = rmrow(y, s)


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [20; 0]
ax = Axis(f[1, 1]; xlabel = uppercase(nam),  ylabel = "Nb. observations", 
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Density")
bdw = 1
density!(ax, ytrain; bandwidth = bdw, color = :blue, label = "Train")
density!(ax, ytest; bandwidth = bdw, color = (:red, .5), label = "Test")
axislegend(position = :rt)  
f


f = Figure(size = (500, 400))
offs = [.1; 0]
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Density", 
    yticks = (offs, ["Train" ; "Test"]))
bdw = 1
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5), bandwidth = bdw)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5), bandwidth = bdw)
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), xlabel = "Group", ylabel = uppercase(nam))
boxplot!(ax, test, y; width = .3, show_notch = true)
f

