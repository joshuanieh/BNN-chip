#This is file is used to generate the testbench data for BNN, but the actual scenario for the BCNN is the data is related to previous data
import torch
import torch.nn as nn
import random
def generate_kernel_data():
    data_list = []
    weight_list = []
    # skip_list = []
    output_list = []

    for i in range(100):
        data = torch.randn(1,1,3,3).sign()                  #Binarized input
        conv2d = nn.Conv2d(1,1,3)
        conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
        conv2d.bias.data = torch.tensor([0])
        # skip = random.randint(0,8)
        # for i in range(skip):
        #     conv2d.weight.data[0][0][2-i//3][2-i%3]=torch.tensor([0])
        #     data[0][0][2-i//3][2-i%3]=torch.tensor([0])
        output = conv2d(data)
        
        data_list += [data.flatten().tolist()]
        weight_list += [conv2d.weight.data.flatten().tolist()]
        # skip_list += [skip]
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
            
    # with open('skip.dat', 'w') as f:
    #     for i in skip_list:
    #         skip_string = ""
    #         if i == 0:
    #             skip_string = "0000"
    #         elif i == 1:
    #             skip_string = "0001"
    #         elif i == 2:
    #             skip_string = "0010"
    #         elif i == 3:
    #             skip_string = "0011"
    #         elif i == 4:
    #             skip_string = "0100"
    #         elif i == 5:
    #             skip_string = "0101"
    #         elif i == 6:
    #             skip_string = "0110"
    #         elif i == 7:
    #             skip_string = "0111"
    #         elif i == 8:
    #             skip_string = "1000"

    #         f.write(skip_string + '\n')
            
    with open('golden.dat', 'w') as f:
        for i in output_list:
            output_string = ""
            if i == -9:
                output_string = "1110111"
            elif i == -8:
                output_string = "1111000"
            elif i == -7:
                output_string = "1111001"
            elif i == -6:
                output_string = "1111010"
            elif i == -5:
                output_string = "1111011"
            elif i == -4:
                output_string = "1111100"
            elif i == -3:
                output_string = "1111101"
            elif i == -2:
                output_string = "1111110"
            elif i == -1:
                output_string = "1111111"
            elif i == 0:
                output_string = "0000000"
            elif i == 1:
                output_string = "0000001"
            elif i == 2:
                output_string = "0000010"
            elif i == 3:
                output_string = "0000011"
            elif i == 4:
                output_string = "0000100"
            elif i == 5:
                output_string = "0000101"
            elif i == 6:
                output_string = "0000110"
            elif i == 7:
                output_string = "0000111"
            elif i == 8:
                output_string = "0001000"
            elif i == 9:
                output_string = "0001001"

            f.write(output_string + '\n')
    '''
    According to the definition of initialization of conv2d weights, the values are bound in +- 1/3=0.3333333...

    def reset_parameters(self):
        n = self.in_channels
        for k in self.kernel_size:
            n *= k
        stdv = 1. / math.sqrt(n)
        self.weight.data.uniform_(-stdv, stdv)
        if self.skip is not None:
            self.skip.data.uniform_(-stdv, stdv)
    '''

def generate_systolic_array_data():
    # weight_list = []
    k=10#3*row_length*k=i_ch, a PE has 3 channels, k runs
    row_length=10
    o_ch=6
    i_ch=(3*row_length+2)*k
    data_list = []
    data = torch.randn(1,i_ch,3,3).sign()                  #Binarized input
    conv2d = nn.Conv2d(i_ch,o_ch,3)
    conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
    conv2d.bias.data = torch.tensor([0. for z in range(o_ch)])
    output = conv2d(data)
    # print(data[0])
    # print(conv2d.weight.data)

    for m in range(k):
        for i in conv2d.weight.data: #o_ch iterations
            count = 0
            for j in i[m*(row_length*3+2):(m+1)*(row_length*3+2)]: #take 3*row_length channels, a PE has 3 channels
                if count % 3 == 0:
                    data_list += [j.flatten().tolist()]#weight, 3 should be batched together
                else:
                    data_list[-1] += j.flatten().tolist()
                
                count += 1
                if count == 32:
                    data_list[-1] += [0 for t in range(9)]
                    count = 0


        count = 0
        for i in data[0][m*(row_length*3+2):(m+1)*(row_length*3+2)]: #i_ch iterations
            if count == 0:
                data_list += [i.flatten().tolist()]
            else:
                data_list[-1] += i.flatten().tolist()
            count += 1
            count %= 3

        data_list[-1] += [0 for t in range(9)]

        # with open('weight.dat', 'w') as f:
        #     for i in weight_list:
        #         weight_string = ""
        #         for j in i:
        #             if j == -1:
        #                 weight_string += '0'
        #             else:
        #                 weight_string += '1'

        #         f.write("".join(weight_string) + '\n')
        
        with open('data.dat', 'w') as f:
            for i in data_list:
                data_string = ""
                for j in i:
                    if j == -1:
                        data_string += '0'
                    else:
                        data_string += '1'

                f.write(data_string + '\n')

    with open('golden.dat', 'w') as f:
        for i in output.data.flatten().tolist():
            i = int(i)
            output_string = ""
            # print(i, end=": ")
            if i >= 0:
                output_string = '{:014b}'.format(i)
            else:
                i = (abs(i)-1)
                complement_string = '{:014b}'.format(i)
                output_list = ['0' if i == '1' else '1' for i in complement_string]
                output_string = "".join(output_list)
            # print(output_string)
            f.write(output_string + '\n')


generate_systolic_array_data()