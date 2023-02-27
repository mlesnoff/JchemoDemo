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

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

rep = 30
ids = mtest(Y[:, namy]; test = .30, 
    rep = rep) ;
pnames(ids)
## i : variable in Y
## j : replication
idtrain = ids.train
idtest = ids.test

res = list(nvar)
zres = list(rep)
for i = 1:nvar
    nam = namy[i]
    println("")
    println(i, "----- ", nam)
    y = Y[:, nam]
    for j = 1:rep
        print(j, " ")
        ## Data
        strain = idtrain[i][j] 
        stest = idtest[i][j]  
        Xtrain = Xp[strain, :] 
        ytrain = y[strain] 
        Xtest = Xp[stest, :] 
        ytest = y[stest] 
        ntrain = length(ytrain)
        ntest = length(ytest)
        ntot = ntrain + ntest
        (ntot = ntot, ntrain, ntest)
        ## K-Fold CV
        K = 3
        segm = segmkf(ntrain, K; rep = 5)
        ## Or "test-set" CV
        #pct = .30
        #m = pct * ntot
        #segm = segmts(ntrain, m; rep = 30)
        nlv = 0:30
        z = gridcvlv(Xtrain, ytrain; segm = segm, 
            score = rmsep, fun = plskern, nlv = nlv, 
            verbose = false).res
        n = nro(z)
        u = findall(z.y1 .== minimum(z.y1))[1]
        z.opt = zeros(n)
        z.opt[u] = 1
        z.repl = repeat([j], n)
        z.nam = repeat([nam], n)
        zres[j] = z
    end
    res[i] = reduce(vcat, zres)
end

## If exportation of the results
resval = (res = res, namy) 
root = "D:/Mes Donnees/Tmp/"
db = string(root, "resval_tecator.jld2") 
#@save db resval
## End

## ---- OBJECTIVE 1
## Select the best model over the replications
## (splitting Train+Test) and estimate its 
## generalization error
i = 1
namy[i]
z = res[i] 
## Variability between the replications
plotgrid(z.nlv, z.y1, z.repl;
    xlabel = "Nb. LVs", ylabel = "RMSEP",
    leg = false).f
## Choice of the best model
zres = z[z.opt .== 1, :]
ztab = tab(zres.nlv)
barplot(ztab.lev, ztab.ni;
    axis = (xticks = minimum(ztab.lev):maximum(ztab.lev),
        xlabel = "Nb. LVs", ylabel = "Nb. occurences"))
u = findall(ztab.ni .== maximum(ztab.ni))[1]
nlv = ztab.lev[u]



u = findall(z.y1 .== minimum(z.y1))[1]
z.opt = zeros(nro(z))
z.opt[u] = 1








