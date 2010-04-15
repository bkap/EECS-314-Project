from __future__ import print_function
import subprocess
import os.path
EPSILON = 1e-10
def main() :
    dir = os.path.abspath(os.path.dirname(__file__))
    test_cases = open(dir + '/tests', 'r')
    proc = subprocess.Popen(['spim','-f',dir +'/calc.s'], 
        stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    #get rid of the first part
    for i in range(5) :
        proc.stdout.readline()
    for test in test_cases.readlines() :
        input, result = test.strip().split('\t')
        proc.stdin.write(input.encode('utf-8') + b'\n')
        proc.stdin.flush()
        actual = proc.stdout.readline().strip()
        print(input, '=',actual.decode('utf-8'),':',abs(float(result)-float(actual)) < EPSILON)
    test_cases.close()
    proc.communicate(b'quit\n')

if __name__ == '__main__' :
    main()
