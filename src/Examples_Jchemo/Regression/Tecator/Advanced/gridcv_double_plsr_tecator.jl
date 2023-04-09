using JLD2, CairoMakie
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
typ = Y.typ
namy = names(Y)[1:3]
nvar = length(namy)

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## The objective of this script is to do a double 
## replicated cross-validation
## ==> Computation of
## a) the model selection 
## b) the generalization error.
## The steps are
## - 1) Replication of the splitting {Train, Test}
## - 2) Replicated CV within each Train
## - 3) Performance on each Test

## Replicated splitting Train+Test
## using funcion 'mtest'
rep = 100
pct = .40
ids = mtest(Y[:, namy]; test = pct, 
    rep = rep) ;
pnames(ids)
j = 1 # y-variable
k = 2 # replication
ids.train[j]
ids.test[j]
ids.train[j][k]
ids.test[j][k]

idtrain = ids.train
idtest = ids.test

## CV within each Train of each replication,
## for each y-variable 
rescv = list(nvar)
zres = list(rep)
for j = 1:nvar
    nam = namy[j]  # y-variable
    println("")
    println(j, "----- ", nam)
    y = Y[:, nam]
    for k = 1:rep  # replication
        print(k, " ")
        strain = idtrain[j][k] 
        Xtrain = Xp[strain, :] 
        ytrain = y[strain] 
        ntrain = length(ytrain)
        ## Replicated K-Fold CV within the given Train
        K = 5
        segm = segmkf(ntrain, K; rep = 5)
        ## Or Replicated "test-set" CV within the given Train
        #pct = .20
        #m = pct * ntot
        #segm = segmts(ntrain, m; rep = 30)
        nlv = 0:25
        z = gridcvlv(Xtrain, ytrain; segm = segm, 
            score = rmsep, fun = plskern, nlv = nlv, 
            verbose = false).res
        ## Index of the best model within the replication
        ## (facultative)
        u = findall(z.y1 .== minimum(z.y1))[1]
        n = nro(z)
        z.opt = [if k == u 1 else 0 end ; for k = 1:n]
        ## End
        z.repl = repeat([k], n)
        z.nam = repeat([nam], n)
        zres[k] = z
    end
    rescv[j] = reduce(vcat, zres)
end
length(rescv) 
rescv[1] # y-variable

## If exportation of the results
root = "D:/Mes Donnees/Tmp/"
db = string(root, "rescv_tecator.jld2") 
#@save db rescv
## End

## Variability of RMSECV
## between the replications {Train, Test},
## for a given y-variable
j = 1  # y-variable
namy[j]
## RMSECV
zres = rescv[j] 
plotgrid(zres.nlv, zres.y1, zres.repl; title = namy[j],
    xlabel = "Nb. LVs", ylabel = "RMSEP (Test)",
    leg = false).f
## Most occurent best models
z = zres[zres.opt .== 1, :]
ztab = tab(z.nlv)
lev = ztab.keys 
ni = ztab.vals
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[j],
    xticks = minimum(lev):2:maximum(lev),
    xlabel = "Nb. LVs", ylabel = "Nb. occurences")
barplot!(ax, lev, ni)
f

## One question is to estimate 
## the performance (= generalization or Test error) 
## of *PLSR* over the full dataset X,y
## (this is a relevant approach to compare the performance
## of different types of models). 
## For each replication Train+Test, the indicator is 
## the generalization error of the *best* model 
## selected by CV on the given Train for the replication. 
## Below, the distribution of this indicator over the replications
## is computed, for each y-variable
res_mse = list(nvar, DataFrame)
for j = 1:nvar
    nam = namy[j]  # y-variable
    y = Y[:, nam]
    for k = 1:rep  # replication
        strain = idtrain[j][k]
        stest = idtest[j][k]  
        Xtrain = Xp[strain, :] 
        ytrain = y[strain] 
        Xtest = Xp[stest, :] 
        ytest = y[stest]
        ## Facultative 
        ntrain = length(ytrain)
        ntest = length(ytest)
        ntot = ntrain + ntest
        (ntot = ntot, ntrain, ntest)
        ## Selection of the best model within 
        ## the replication
        z = rescv[j]
        zres = z[z.repl .== k, :]
        u = findall(zres.opt .== 1)[1]
        ## If opt does not exist
        #u = findall(zres.y1 .== minimum(zres.y1))[1]
        ## Prediction of Test (generalization error)
        fm = plskern(Xtrain, ytrain; nlv = zres.nlv[u]) ;
        pred = Jchemo.predict(fm, Xtest).pred
        z = mse(pred, ytest)
        z.namy = [nam]
        k == 1 ? res_mse[j] = z : res_mse[j] = vcat(res_mse[j], z)
    end
end
res_mse[1]  # y-variable
## Description of the distribution of RMSEP_Test,
## for a given y-variable
j = 1  # y-variable
namy[j]
zres = res_mse[j] 
summ(zres)
mean(zres.rmsep)  # mean RMSEP_Test 
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[j],
    xlabel = "RMSEP", ylabel = "Nb. occurences")
hist!(ax, zres.rmsep; bins = 30)
f

## Another question is to select a unique 
## best model over the replications,
## and to estimate its average generalization error.
## Below, the best model over the replications is selected 
## and its generalization error is estimated,
## for a given y-variable
j = 1  # y-variable
nam = namy[j]
y = Y[:, nam]
res = rescv[j] 
## Find the best model over the replications
## a) in average
zres = aggstat(res; vars = :y1, groups = :nlv,
    fun = mean)
plotgrid(zres.nlv, zres.y1;
    xlabel = "Nb. LVs", ylabel = "RMSEP").f
u = findall(zres.y1 .== minimum(zres.y1))[1]
zres[u, :]
nlv = zres.nlv[u]  # final model
## b) or the most occurent
zres = res[res.opt .== 1, :]
ztab = tab(zres.nlv)
lev = ztab.keys 
ni = ztab.vals
u = findall(ni .== maximum(ni))[1]
nlv = lev[u]  # final model
## Prediction of Test by the final model
## and generalization  error
res_mse_avg = nothing
for k = 1:rep  # replication
    strain = idtrain[j][k] 
    stest = idtest[j][k]  
    Xtrain = Xp[strain, :] 
    ytrain = y[strain] 
    Xtest = Xp[stest, :] 
    ytest = y[stest]
    fm = plskern(Xtrain, ytrain; nlv = nlv) ;
    pred = Jchemo.predict(fm, Xtest).pred
    z = mse(pred, ytest)
    z.namy = [nam]
    k == 1 ? res_mse_avg = z : res_mse_avg = vcat(res_mse_avg, z)
end
res_mse_avg
## Description of the distribution of RMSEP_Test
summ(res_mse_avg)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[j],
    xlabel = "RMSEP", ylabel = "Nb. occurences")
hist!(ax, res_mse_avg.rmsep; bins = 30)
f


