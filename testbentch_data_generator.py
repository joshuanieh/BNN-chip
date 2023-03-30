#This is file is used to generate the testbench data for BNN, but the actual scenario for the BCNN is the data is related to previous data
import torch
import torch.nn as nn

data_list = []
weight_list = []
bias_list = []
output_list = []

for i in range(100):
    data = torch.randn(1,1,3,3).sign()                  #Binarized input
    conv2d = nn.Conv2d(1,1,3)
    conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
    conv2d.bias.data = torch.randint(-8,8,(1,))         #Bound bias in four bits, thought 3*3 kernel has max popcount = 9, min = -9, -8~7 is a great range and using only 4 bits
    output = conv2d(data).sign()
    
    data_list += [data.flatten().tolist()]
    weight_list += [conv2d.weight.data.flatten().tolist()]
    bias_list += [conv2d.bias.item()]
    output_list += [output.item()]

with open('data.dat', 'w') as f:
    for i in data_list:
        data_string = ""
        for j in i:
            if j == -1:
                data_string += '0'
            else:
                data_string += '1'

        f.write("".join(data_string) + '\n')

with open('weight.dat', 'w') as f:
    for i in weight_list:
        weight_string = ""
        for j in i:
            if j == -1:
                weight_string += '0'
            else:
                weight_string += '1'

        f.write("".join(weight_string) + '\n')
        
with open('bias.dat', 'w') as f:
    for i in bias_list:
        bias_string = ""
        if i == -8:
            bias_string = "1000"
        elif i == -7:
            bias_string = "1001"
        elif i == -6:
            bias_string = "1010"
        elif i == -5:
            bias_string = "1011"
        elif i == -4:
            bias_string = "1100"
        elif i == -3:
            bias_string = "1101"
        elif i == -2:
            bias_string = "1110"
        elif i == -1:
            bias_string = "1111"
        elif i == 0:
            bias_string = "0000"
        elif i == 1:
            bias_string = "0001"
        elif i == 2:
            bias_string = "0010"
        elif i == 3:
            bias_string = "0011"
        elif i == 4:
            bias_string = "0100"
        elif i == 5:
            bias_string = "0101"
        elif i == 6:
            bias_string = "0110"
        elif i == 7:
            bias_string = "0111"

        f.write(bias_string + '\n')
        
with open('output.dat', 'w') as f:
    for i in output_list:
        output_string = ""
        if i == -1:
            output_string = '0'
        else:
            output_string = '1'

        f.write(output_string + '\n')
'''
According to the definition of initialization of conv2d weights, the values are bound in +- 1/3=0.3333333...

def reset_parameters(self):
    n = self.in_channels
    for k in self.kernel_size:
        n *= k
    stdv = 1. / math.sqrt(n)
    self.weight.data.uniform_(-stdv, stdv)
    if self.bias is not None:
        self.bias.data.uniform_(-stdv, stdv)
'''