#!/usr/bin/env python3

import matplotlib.pyplot as plt
import subprocess  
from dataclasses import dataclass

def run(L, N, seed):
    return subprocess.check_output(["./main", str(L), str(N), str(seed)]).decode(encoding='ascii').replace('\n','')

@dataclass
class DResult:
    L: int 
    N: int
    seed: int
    checksum: int 
    average: float

    @staticmethod
    def parse(d):
        l = [v.strip() for v in d.split(',')]
        assert len(l) == 5
        return DResult(int(l[0]),
                       int(l[1]),
                       int(l[2]),
                       int(l[3]),
                       float(l[4]))



x = list(range(2,2048,2))
d = [ DResult.parse(run(l,200,565654)) for l in x ]
ay,sy= zip(*[(v.average,v.checksum) for v in d])

fig, (axc, axa) = plt.subplots(nrows=2, ncols=1)

axc.set_title('sum of all hamming distances')
axc.plot(x,sy)

axa.set_title('average of all hamming distances')
axa.plot(x,ay)

plt.show()


print(DResult.parse(run(12,100,123123123)))

