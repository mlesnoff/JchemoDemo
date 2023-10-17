using JLD2, CairoMakie, StatsBase, DataFrames
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
typ = Y.typ
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
namy = names(Y)[1:3]
nvar = length(namy)

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Double replicated cross-validation
## with two objectives:
## a) the model selection 
## b) the generalization error

## The steps are
## - 1) Replication of the splitting {Train, Test}
## - 2) Replicated CV within each Train
## - 3) Performance on each Test

## Replicated splitting Train/Test
## using funcion 'mtest'
rep = 100
ntest = 60
ids = [mtest(Y[:, namy]; ntest = 60) for i = 1:rep]
length(ids)
i = 1    # replication
ids[i]
ids[i].train 
ids[i].test
j = 1    # variable y  
ids[i].train[j]
ids[i].test[j]
ids[i].nam[j]

## CV within each replication and Train,
## for each variable y
rescv = list(nvar, DataFrame)
res = list(rep)
for j = 1:nvar
    nam = namy[j]  # y-variable
    println("")
    println(j, "----- ", nam)
    y = Y[:, nam]
    for i = 1:rep  # replication
        print(i, " ")
        strain = ids[i].train[j] 
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
        zres = gridcvlv(Xtrain, ytrain; segm = segm, 
            score = rmsep, fun = plskern, nlv = nlv, 
            verbose = false).res
        ## Index of the best model within the replication
        ## (facultative)
        u = findall(zres.y1 .== minimum(zres.y1))[1]
        n = nro(zres)
        zres.opt = [if k == u 1 else 0 end ; for k = 1:n]
        ## End
        zres.repl = repeat([i], n)
        zres.nam = repeat([nam], n)
        res[i] = zres
    end
    rescv[j] = reduce(vcat, res)
end
length(rescv) 
rescv[1] # variable y

## If exportation of the results
path_out = "D:/Mes Donnees/Tmp"
db = joinpath(path_out, "rescv_tecator.jld2") 
#@save db rescv
## End

## Variability of RMSEP-CV
## between the replications Train,
## for a given y-variable
j = 1  # variable y
namy[j]
## RMSEP-CV
res = rescv[j] 
plotgrid(res.nlv, res.y1, res.repl; title = namy[j],
    xlabel = "Nb. LVs", ylabel = "RMSEP-CV",
    leg = false).f
## Most occurent best models
z = res[res.opt .== 1, :]
ztab = tab(z.nlv)
lev = ztab.keys 
ni = ztab.vals
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[j],
    xticks = minimum(lev):2:maximum(lev),
    xlabel = "Nb. LVs", ylabel = "Nb. occurences")
barplot!(ax, lev, ni)
f

## Estimate the overall performance (= generalization or 
## Test error) of PLSR over the full dataset {X, y}
## (relevant approach to compare the performance
## of different types of models). 
## For each replication Train/Test, the indicator is 
## the generalization error (= RMSEP-Test) of the 
## *best* model selected by CV on Train for the replication. 
## Below, the distribution of this indicator over the 
## replications is computed, for each y-variable
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
        ## Selection of the best model 
        ## within the replication
        z = rescv[j]
        res = z[z.repl .== k, :]
        u = findall(res.opt .== 1)[1]
        ## If opt does not exist
        #u = findall(res.y1 .== minimum(res.y1))[1]
        ## Prediction of Test (generalization error)
        fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
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
res = res_mse[j] 
summ(res)
mean(res.rmsep)  # mean RMSEP_Test 
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[j],
    xlabel = "RMSEP", ylabel = "Nb. occurences")
hist!(ax, res.rmsep; bins = 30)
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
res = aggstat(res; vars = :y1, groups = :nlv,
    fun = mean)
plotgrid(res.nlv, res.y1;
    xlabel = "Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
nlv = res.nlv[u]  # final model
## b) or the most occurent
res = res[res.opt .== 1, :]
ztab = tab(res.nlv)
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

