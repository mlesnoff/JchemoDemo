using JLD2, CairoMakie
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
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

## Double replicated cross-validation
## ==> Model selection + Generalization error
## - (1) Replications of the splitting Train+Test
## - (2) Replicated CV within each Train
## - (3) Performance on each Test

## Splitting Train+Test
rep = 80
ids = mtest(Y[:, namy]; test = .40, 
    rep = rep) ;
pnames(ids)
## i : variable in Y
## j : replication
idtrain = ids.train
idtest = ids.test
length(idtrain)
length(idtest)
idtrain[1]
idtest[1]

## Cross-Validation within Train over the replications 
## Train+Test ==> RMSECV (within Train) for each 
## replication
rescv = list(nvar)
zres = list(rep)
for i = 1:nvar
    ## Variable
    nam = namy[i]
    println("")
    println(i, "----- ", nam)
    y = Y[:, nam]
    for j = 1:rep
        ## Replication of splitting Train+Test
        print(j, " ")
        strain = idtrain[i][j] 
        Xtrain = Xp[strain, :] 
        ytrain = y[strain] 
        ntrain = length(ytrain)
        ## Replicated K-Fold CV within Train
        K = 5
        segm = segmkf(ntrain, K; rep = 5)
        ## Or Replicated "test-set" CV within Train
        #pct = .20
        #m = pct * ntot
        #segm = segmts(ntrain, m; rep = 30)
        nlv = 0:25
        z = gridcvlv(Xtrain, ytrain; segm = segm, 
            score = rmsep, fun = plskern, nlv = nlv, 
            verbose = false).res
        ## Index of the best model within the replication
        # (facultative)
        u = findall(z.y1 .== minimum(z.y1))[1]
        n = nro(z)
        z.opt = [if k == u 1 else 0 end ; for k = 1:n]
        ## End
        z.repl = repeat([j], n)
        z.nam = repeat([nam], n)
        zres[j] = z
    end
    rescv[i] = reduce(vcat, zres)
end
length(rescv) 
rescv[1]

## If exportation of the results
root = "D:/Mes Donnees/Tmp/"
db = string(root, "rescv_tecator.jld2") 
#@save db rescv
## End

## Variability of RMSECV
## over the replications Train+Test
i = 1
namy[i]
## RMSECV
zres = rescv[i] 
plotgrid(zres.nlv, zres.y1, zres.repl; title = namy[i],
    xlabel = "Nb. LVs", ylabel = "RMSEP (Test)",
    leg = false).f
## Most occurent best models
z = zres[zres.opt .== 1, :]
ztab = tab(z.nlv)
lev = ztab.keys 
ni = ztab.vals
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[i],
    xticks = minimum(lev):2:maximum(lev),
    xlabel = "Nb. LVs", ylabel = "Nb. occurences")
barplot!(ax, lev, ni)
f

## Estimate of the global performance (generalization error) 
## of PLSR over the full dataset X,y
## (relevant approach to compare performances of 
## different types of models). 
## For each replication Train+test, the indicator is 
## the generalization (= Test) error of the best model 
## selected by CV (Train) for the replication. 
## The distribution of this indicator over the replications
## is computed
res_mse = list(nvar, DataFrame)
for i = 1:nvar
    ## Variable
    nam = namy[i]
    y = Y[:, nam]
    for j = 1:rep
        ## Replication (splitting Train+Test)
        strain = idtrain[i][j] 
        stest = idtest[i][j]  
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
        z = rescv[i]
        zres = z[z.repl .== j, :]
        u = findall(zres.opt .== 1)[1]
        ## If opt does not exist
        #u = findall(zres.y1 .== minimum(zres.y1))[1]
        ## Prediction of Test (generalization error)
        fm = plskern(Xtrain, ytrain; nlv = zres.nlv[u]) ;
        pred = Jchemo.predict(fm, Xtest).pred
        z = mse(pred, ytest)
        z.namy = [nam]
        j == 1 ? res_mse[i] = z : res_mse[i] = vcat(res_mse[i], z)
    end
end
res_mse[1]
## Description of the distribution of RMSEP_Test
i = 1
namy[i]
z = res_mse[i] 
summ(z)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[i],
    xlabel = "RMSEP", ylabel = "Nb. occurences")
hist!(ax, z.rmsep; bins = 30)
f

## What is the best model over the replications
## and what is its generalization error
## Select the best model over 
## the replications (splitting Train+Test) and 
## estimate its generalization error (RMSEP_TEST)
i = 1
namy[i]
zres = rescv[i] 
## Best model over the replications
## - in average
z = aggstat(zres; vars = :y1, groups = :nlv,
    fun = mean)
plotgrid(z.nlv, z.y1;
    xlabel = "Nb. LVs", ylabel = "RMSEP").f
u = findall(z.y1 .== minimum(z.y1))[1]
z[u, :]
## Or the most occurent
z = zres[zres.opt .== 1, :]
ztab = tab(z.nlv)
lev = ztab.keys 
ni = ztab.vals
u = findall(ni .== maximum(ni))[1]
nlv = lev[u]
## Prediction of Test by the final model
## and generalization  error
res_mse = list(nvar, DataFrame)
for i = 1:nvar
    ## Variable
    nam = namy[i]
    y = Y[:, nam]
    for j = 1:rep
        ## Replication (splitting Train+Test)
        strain = idtrain[i][j] 
        stest = idtest[i][j]  
        Xtrain = Xp[strain, :] 
        ytrain = y[strain] 
        Xtest = Xp[stest, :] 
        ytest = y[stest]
        fm = plskern(Xtrain, ytrain; nlv = nlv) ;
        pred = Jchemo.predict(fm, Xtest).pred
        z = mse(pred, ytest)
        z.namy = [nam]
        j == 1 ? res_mse[i] = z : res_mse[i] = vcat(res_mse[i], z)
    end
end
res_mse[1]
## Description of the distribution of RMSEP_Test
i = 1
namy[i]
z = res_mse[i] 
summ(z)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], title = namy[i],
    xlabel = "RMSEP", ylabel = "Nb. occurences")
hist!(ax, z.rmsep; bins = 30)
f

