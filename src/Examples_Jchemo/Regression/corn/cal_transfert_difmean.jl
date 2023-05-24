using JLD2, CairoMakie, FreqTables
using Jchemo, JchemoData
using GLMakie
CairoMakie.activate!()  

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/corn.jld2") 
@load db dat
pnames(dat)
Xm5 = dat.Xm5
Xmp5 = dat.Xmp5
Xmp6 = dat.Xmp6
Xm5nbs = dat.Xm5nbs
Xmp5nbs = dat.Xmp5nbs
Xmp6nbs = dat.Xmp6nbs
Y = dat.Y 
ntot = nro(Xm5)
wl = names(dat.Xm5)
wl_num = parse.(Float64, wl)

summ(Y).res

plotsp(Xm5, wl_num).f

fpreproc(X) = savgol(snv(X); f = 11, d = 2, pol = 3) 
Xpm5 = fpreproc(Xm5)
Xpmp5 = fpreproc(Xmp5)
Xpmp6 = fpreproc(Xmp6)




m = ntot / 2
res = sampdp(hcat(X1, X2); k = m) ;
pnames(res)
res.train
res.test
res.remain
s = vcat(res.train, res.remain)
X1train = X1[s, :]
Y1train = Y[s, :]
X1test = rmrow(X1, s)
Y1test = rmrow(Y, s)
##
X2test = X2[s, :]
Y2test = Y[s, :]
X2train = rmrow(X2, s)
Y2train = rmrow(Y, s)
##
n1train = nro(X1train)
n1test = nro(X1test)
n2train = nro(X2train)
n2test = nro(X2test)
(n1 = n1, n2, n1train, n1test, n2train, n2test)

summ(Y).res
j = 1
println(namy[j])
y1train = Y1train[:, j]
y1test = Y1test[:, j]
y2train = Y2train[:, j]
y2test = Y2test[:, j]

zX = copy(X1train) ; zy = copy(y1train) ; zn = copy(n1train) ; zXtest = copy(X1test) ; zytest = copy(y1test) 
#zX = copy(X2train) ; zy = copy(y2train) ; zn = copy(n2train) ; zXtest = copy(X2test) ; zytest = copy(y2test) 
K = 5
segm = segmkf(zn, K; rep = 20)
nlv = 0:15
res = gridcvlv(zX, zy; segm = segm,
    score = rmsep, fun = plskern, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = plskern(zX, zy; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f

nlv0 = 10 ; rep = 1000
D = Jchemo.mcdif(X1train, X2train; rep = rep).D
scor = nothing
for a = 1:nlv0
    D = Jchemo.difload(X1train, X2train; nlv = nlv0).D
    M = eposvd(D; nlv = a).M
    zX = X1train * M ; zy = copy(y1train) ; zn = copy(n1train)
    #zX = X2train * M ; zy = copy(y2train) ; zn = copy(n2train)
    K = 5
    segm = segmkf(zn, K; rep = 20)
    nlv = 0:15
    res = gridcvlv(zX, zy; segm = segm,
        score = rmsep, fun = plskern, nlv = nlv).res
    plotgrid(res.nlv, res.y1).f
    u = findall(res.y1 .== minimum(res.y1))[1]
    a == 1 ? scor = DataFrame(res[u, :]) : scor = vcat(scor, DataFrame(res[u, :]))
end
insertcols!(scor, 1, :nlv0 => 1:nlv0)
u = findall(scor.y1 .== minimum(scor.y1))[1]
scor[u, :]
plotgrid(1:nlv0, scor.y1; step = 2).f    
#plotgrid(1:nlv0, scor.nlv; step = 2).f

nlv0 = 1 ; nlv = 6    # j = 1
#nlv0 = 1 ; nlv = 8    # j = 3
#nlv0 = 1 ; nlv = 5    # j = 4
#nlv0 = 5 ; nlv = 5    # j = 4
rep = 1000
res = difmean(X1train, X2train)
#res = Jchemo.mcdif(X1train, X2train; rep = rep)
#res = Jchemo.difload(X1train, X2train; nlv = nlv0)
#res = Jchemo.udop(X1train, X2train; nlv = nlv0)
fm0 = eposvd(res.D; nlv = nlv0) ;
zX = X1train * fm0.M ; zy = copy(y1train)
zXtest = copy(X1test) ; zytest = copy(y1test)
#zXtest = copy(X2test) ; zytest = copy(y2test)
#zXtest = X1test * fm0.M    # not required if PLSR (othogonalization is embedded) 
#zXtest = X2test * fm0.M    # not required if PLSR (othogonalization is embedded) 
fm = plskern(zX, zy; nlv = nlv) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f


D = res.D
P = fm0.P

P * P'
D' * inv(D * D') * D





## High: good example but only 1 nlv (difmean is enough,
## but mcdif, difload works good)  
## Improve the tuning: separate X2 to train+test (X2train
## used to compute D; X2test should never be used in the calibration)

sourcedir(path_fun)
nlv0 = 1 ; nlv = 27   # Mid
#nlv0 = 1 ; nlv = 27   # High
res = Jchemo.difmean(X1, X2train)
fm0 = eposvd(res.D; nlv = nlv0) ;
X1_transf = X1 * fm0.M
zX2 = copy(X2test)
#zX2 = X2test * fm0.M    # not required if PLSR (othogonalization is embedded) 
fm = plskern(X1_transf, y1; nlv = nlv) ;
pred = Jchemo.predict(fm, zX2).pred
println(rmsep(pred, y2test))
plotxy(vec(pred), y2test;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f

sourcedir(path_fun)
z1 = rand(2, 10)
z2 = 3 * z1
res = Jchemo.difmean(z1, z2)
res.D
fm0 = eposvd(res.D; nlv = 1) ;
fm0.P
z1 * fm0.M
z2 * fm0.M