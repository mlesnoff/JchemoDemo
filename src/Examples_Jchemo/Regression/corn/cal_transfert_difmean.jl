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
Y = dat.Y 
ntot = nro(Xm5)
wl = names(dat.Xm5)
wl_num = parse.(Float64, wl)
namy = names(Y)

summ(Y).res

plotsp(Xm5, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Reflectance").f

fpreproc(X) = savgol(snv(X); f = 11, d = 2, pol = 3) 
Xpm5 = fpreproc(Xm5)
Xpmp5 = fpreproc(Xmp5)
Xpmp6 = fpreproc(Xmp6)

## Data selection (machines 1 and 2) for the example
X1 = copy(Xpm5)
X2 = copy(Xpmp6)    
m = ntot / 2
res = sampdp(hcat(X1, X2); k = m) ;
pnames(res)
res.train
res.test
s = res.train
## Machine 1
X1train = X1[s, :]
Y1train = Y[s, :]
X1test = rmrow(X1, s)
Y1test = rmrow(Y, s)
## Machine 2
X2test = X2[s, :]
Y2test = Y[s, :]
X2train = rmrow(X2, s)
Y2train = rmrow(Y, s)
## End
n1train = nro(X1train)
n1test = nro(X1test)
n2train = nro(X2train)
n2test = nro(X2test)
(n1 = n1, n2, n1train, n1test, n2train, n2test)

## Selection of the y-variable
j = 1  
println(namy[j])
y1train = Y1train[:, j]
y1test = Y1test[:, j]
y2train = Y2train[:, j]
y2test = Y2test[:, j]

#### Model tuning and performance on the reference data (for a given machine)
## On machine 1
zXtrain = copy(X1train) ; zytrain = copy(y1train) ; zn = copy(n1train) ; zXtest = copy(X1test) ; zytest = copy(y1test) 
## On machine 2
#zXtrain = copy(X2train) ; zytrain = copy(y2train) ; zn = copy(n2train) ; zXtest = copy(X2test) ; zytest = copy(y2test) 
K = 5
segm = segmkf(zn, K; rep = 20)
nlv = 0:15
res = gridcvlv(zXtrain, zytrain; segm = segm,
    score = rmsep, fun = plskern, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = plskern(zXtrain, zytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f

#### Model tuning after transfert (for a given machine)
D = Jchemo.difmean(X1train, X2train).D
M = eposvd(D; nlv = 1).M
zXtrain = X1train * M ; zytrain = copy(y1train) ; zn = copy(n1train) 
#zXtrain = X2train * M ; zytrain = copy(y2train) ; zn = copy(n2train) 
K = 5
segm = segmkf(zn, K; rep = 20)
nlv = 0:15
res = gridcvlv(zXtrain, zytrain; segm = segm,
    score = rmsep, fun = plskern, nlv = nlv).res
plotgrid(res.nlv, res.y1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]

#### Model performance after transfert 
res = difmean(X1train, X2train)
fm0 = eposvd(res.D; nlv = nlv0) ;
## On X1
zXtrain = X1train * fm0.M
zytrain = copy(y1train)
zXtest = copy(X1test)
#zXtest = X1test * fm0.M    # not required if PLSR (othogonalization is embedded) 
zytest = copy(y1test)
## On X2
#zXtrain = X2train * fm0.M
#zytrain = copy(y2train)
#zXtest = copy(X2test)
#zXtest = X1test * fm0.M    # not required if PLSR (othogonalization is embedded) 
#zytest = copy(y2test)
## End
nlv = 7   # depends on X1 vs X2 and y-variable
fm = plskern(zXtrain, zytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f






fm = plskern(zXtrain, zytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f


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








X1 = copy(Xpm5) ; X2 = copy(Xpmp6)
res = Jchemo.difmean(X1, X2) ;
fm0 = eposvd(res.D; nlv = 1) ;
X1c = X1 * fm0.M
X2c = X2 * fm0.M
zX1 = copy(X1) ; zX2 = copy(X2)
#zX1 = copy(X1c) ; zX2 = copy(X2c)
fm = pcasvd(zX1; nlv = 10) ;
T1 = fm.T
T2 = Jchemo.transform(fm, zX2)
i = 1
f, ax = plotxy(T1[:, i:(i + 1)];
    xlabel = string("PC", i), ylabel = string("PC", i + 1))
scatter!(ax, T2[:, i:(i + 1)])
f


