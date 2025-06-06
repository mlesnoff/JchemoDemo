
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
@names dat


X = dat.X ;
Y = dat.Y ;
@head X
@head Y
ntot = nro(X)


wlst = names(X) 
wl = parse.(Int, wlst) ;


plotsp(X, wl; nsamp = 500, xlabel = "Wavelength (nm)").f


model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2) ;
fit!(model, X)
Xp = transf(model, X) ;
@head Xp


plotsp(Xp, wl; nsamp = 500, xlabel = "Wavelength (nm)").f


freqtable(string.(Y.typ, " - ", Y.label))


test = Y.test ;  # training/test (0/1) observations
tab(test) 
freqtable(Y.typ, test)


y = Y.conc ; # protein concentration
summ(y).res


summ(y, test)


s = test .== 0 ;
ytrain = y[s] ;  
ytest = rmrow(y, s) ;


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [70; 0]
ax = Axis(f[1, 1]; xlabel = "Protein",  ylabel = "Nb. observations", 
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Density")
bdw = .5
density!(ax, ytrain; bandwidth = bdw, color = :blue, label = "Train")
density!(ax, ytest; bandwidth = bdw, color = (:red, .5), label = "Test")
axislegend(position = :rt)  
f


f = Figure(size = (400, 300))
offs = [.10; 0]
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Density", 
    yticks = (offs, ["Train" ; "Test"]))
bdw = .5
density!(ax, ytrain; bandwidth = bdw, offset = offs[1], color = (:slategray, 0.5))
density!(ax, ytest; bandwidth = bdw, offset = offs[2], color = (:slategray, 0.5))
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), xlabel = "Group", ylabel = "Protein")
boxplot!(ax, test, y; width = .3, show_notch = true)
f


typ = Y.typ ;
tab(typ)


typ2 = copy(typ) ;
typ2[typ2 .== "val"] .= "test" ;
tab(typ2)


summ(Y, typ2)


namy = names(Y)[1:3]
j = 2
nam = namy[2]
y = Y[:, nam] ;
s = typ2 .== "train" ;
ytrain = y[s] ;  # training observations
ytest = rmrow(y, s) ; # remaing observations

