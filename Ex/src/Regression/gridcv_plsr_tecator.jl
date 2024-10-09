
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y 
ntot = nro(X)


@head X 
@head Y


summ(Y)


namy = names(Y)[1:3]


typ = Y.typ
tab(typ)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv)
model2 = savgol; npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]


K = 3     # nb. folds (segments)
rep = 10  # nb. replications
segm = segmkf(ntrain, K; rep = rep)


#pct = .30
#m = Int(round(pct * ntrain))
#segm = segmts(ntrain, m; rep = 30)


i = 1  
k = 1
segm[i]      # the K segments of replication 'i'


segm[i][k]   # segment 'k' of replication 'i'


model = plskern)
nlv = 0:20
rescv = gridcv(model, Xtrain, ytrain; segm = segm, score = rmsep, nlv, verbose = false) ;
pnames(rescv)


res_rep = rescv.res_rep


group = string.(res_rep.segm, "-", res_rep.rep)
plotgrid(res_rep.nlv, res_rep.y1, group; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP", 
    leg = false).f


res = rescv.res


plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plskern; nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


rmsep(pred, ytest)


f, ax = plotxy(pred, ytest; size = (500, 400), xlabel = "Predicted", ylabel = "Observed")
zpred = vec(pred)
zmod = loessr; span = 2/3) 
fit!(zmod, zpred, ytest)
pred_loess = predict(zmod, sort(zpred)).pred
lines!(ax, sort(zpred), vec(pred_loess); color = :red)
ablines!(ax, 0, 1; color = :grey)
f


res_sel = selwold(res.nlv, res.y1; smooth = false, alpha = .05, graph = true) ;
pnames(res)


res_sel.f       # plots


res_sel.opt     # nb. LVs correponding to the minimal error rate


res_sel.sel     # nb. LVs selected with the Wold's criterion


model = plskern; nlv = res_sel.sel) ;
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
rmsep(pred, ytest)

