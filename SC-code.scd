(
SynthDef(\synth,{arg freq= 220, dur=0.5, mix=0, fold=0.7,amp=1.0,space=0.5,shape=0.6;
	var sig,sig1,sig2,output;
	var gain=freq.explin(60,10000,1.2,0.7);
	var fMod=freq.explin(100,5000,1.0,0.5);
	var env=EnvGen.kr(Env(
		[0.0,1.0,0.0,0.0],
		[0.005+shape.linexp(0,1,0.001,1)*dur,0.02+dur*shape*0.8+dur*shape.linexp(0,1,0.1,1)*0.4,dur*(1+space)]
	), doneAction:2);
	var env2=EnvGen.kr(Env(
		[0.0,0.0,1.0,0],
		[0.01+shape.linexp(0,1,0.01,1)*dur,0.03+dur*shape*0.9+dur*shape.linexp(0,1,0.1,1)*0.5,0.1*dur*(1+space)]
	));
	var imp=freq*(1);
	var fr=freq*(2+env);
	var filFr=(freq*(32+32*env)).min(22000);
	var sim=VOSIM.ar(Impulse.ar(imp), fr, 3, 0.99)-0.5;
	var saw=SyncSaw.ar(freq,freq*(2.3));
	sim=Clip.ar(sim,-1.0,1.0);
	saw=XFade2.ar(saw,sim,mix);
	saw=HPF.ar(saw,freq*2);
	saw=saw+Ringz.ar(saw,freq*4,0.01,0.05);
	saw=PermMod.ar(saw,freq*(3));
	sig2=PermMod.ar(saw,freq*(4));
	saw=HPF.ar(saw,freq);
	sig2=HPF.ar(sig2,freq);
	saw=Fold.ar(saw,fold.neg,fold)*(1/fold);
	sig2=Fold.ar(sig2*(2*env2),fold.neg,fold)*(1/fold);
	saw=MoogFF.ar(saw,filFr,0.5)+SinOsc.ar(freq,mul:0.08)*gain;
	sig2=MoogFF.ar(sig2,filFr*(0.5+0.5*env2),2)+SinOsc.ar(freq,mul:0.07)*gain;
	saw=saw.clip2(1.5)*env*0.1*gain*amp;
	sig2=sig2.clip2(1.5)*(env+(env*env2))*0.1*gain*amp;
	saw=RHPF.ar(saw,freq,0.2);
	sig2=RHPF.ar(sig2,freq,0.2);
	output=saw+[sig2,sig2.neg];
	output=XFade2.ar(TwoTube.ar(output,0.4*space,0.9,400*fMod,300*(fMod-0.2)),output,1-(space*0.7));
	output=XFade2.ar(NHHall.ar(output,(0.8+space*1.2)),output,1-(space*0.8));
	Out.ar(0, output);
}).add
)
(
var toggle=({ |val|
	var newList = Array.newClear(val.size);
	for(0,(val.size-1), { arg i; newList[i] = i%2;});
	newList;
});
var conjugate={ |val|
	var l=val.size;
	var f;
	var newList = Array.newFrom(val);
	var conjugate;
	newList.sort;
	f=newList[l-1];
	conjugate=Array.fill(f,0);
	conjugate[0]=l;
	newList=newList.collect({|item,i| item-1 });
	for(1,f-1, {|i|
		for(0,l-1,{ |j|
			if(newList[j]>0) {
				conjugate[i]=conjugate[i]+1;
				newList[j]=newList[j]-1;
			}
		});
	});
	conjugate
};
var pat1=[0,1,1,0];
var pat2=[2,0,1,2];
var ps=({ |val| Pseq(val) });
var dub=({ |val| Pseq([ps.value(val),2-ps.value(val)]) });
var para=Pseq([dub.value(pat1),dub.value(pat2)],inf);
var dur1=[3,1,2,3,2,1,4];
var dur2=[3,3,2,2,4,2];
var scale=[0,2,3,5,6,9];

Pdef(\bas,Pbind(
	\instrument,\synth,
	\scale,Scale.saba,
	\choice,Pseq(toggle.value(dur1),inf),
	\degree,Pindex(scale,Pkey(\choice),inf),
	\octave,[2,3,4],
	\dur, Pseq(conjugate.value(dur2),inf)*0.5,
	\shape,Pseq([0.9,1],inf),
	\mix,0,
	\fold,Pseq([0.05,0.07],inf),
	\space,Pseq([0.2,1,1],inf),
	\amp,0.7,
));
Pdef(\mid,Pbind(
	\instrument,\synth,
	\scale,Scale.saba,
	\choice,Pseq(toggle.value(dur1),inf),
	\degree,Pindex(scale,Pkey(\choice),inf),
	\octave,[5,6,8],
	\dur, Pseq(dur2,inf)*1,
	\shape,0.8,
	\mix,Pseq([0.5,-0.5],inf),
	\fold,Pseq([0.09,0.7],inf),
	\space,Pseq([0.2,0.9,1],inf),
	\amp,0.6,
));
Pdef(\mid2,Pbind(
	\instrument,\synth,
	\scale,Scale.saba,
	\choice,Pseq(toggle.value(dur1++dur2),inf),
	\degree,Pindex(scale,Pkey(\choice),inf),
	\octave,[4,5,6,7],
	\dur, Pseq(dur1++dur2,inf)*2,
	\shape,Pseq([1.0,0.9],inf),
	\mix,Pseq([0.5,-0.5],inf),
	\fold,Pseq([0.02,0.07],inf),
	\space,Pseq([0.9,0.71,1],inf),
	\amp,0.6,
));
Pdef(\mid3,Pbind(
	\instrument,\synth,
	\scale,Scale.saba,
	\choice,Pseq(toggle.value(dur2),inf),
	\degree,Pindex(scale,Pkey(\choice),inf),
	\octave,[5,6],
	\dur, Pseq(conjugate.value(dur2),inf)*4,
	\shape,Pseq([1,0.9],inf),
	\mix,Pseq([0.5,-0.5],inf),
	\fold,Pseq([0.2,0.6],inf),
	\space,Pseq([0.9,0.81,1],inf),
	\amp,0.5,
));
)

Pdef(\mid).play;
Pdef(\mid2).play;
Pdef(\mid3).play;
Pdef(\bas).play;