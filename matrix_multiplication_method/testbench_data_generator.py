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
    weight_list = []
    data_list = []
    for i in range(1):
        data = torch.randn(1,4,3,3).sign()                  #Binarized input
        conv2d = nn.Conv2d(4,4,3)
        conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
        conv2d.bias.data = torch.tensor([0, 0, 0, 0])
        output = conv2d(data)
        
        for i in conv2d.weight.data:
            for j in i:
                weight_list += [j.flatten().tolist()]

        for i in data[0]:
            data_list += [i.flatten().tolist()]

        with open('weight.dat', 'w') as f:
            for i in weight_list:
                weight_string = ""
                for j in i:
                    if j == -1:
                        weight_string += '0'
                    else:
                        weight_string += '1'

                f.write("".join(weight_string) + '\n')
        
        with open('data.dat', 'w') as f:
            for i in data_list:
                data_string = ""
                for j in i:
                    if j == -1:
                        data_string += '0'
                    else:
                        data_string += '1'

                f.write("".join(data_string) + '\n')

        with open('golden.dat', 'w') as f:
            for i in output.data.flatten().tolist():
                output_string = ""
                if i == -10:
                    output_string = "1111111110110"
                elif i == -9:
                    output_string = "1111111110111"
                elif i == -8:
                    output_string = "1111111111000"
                elif i == -7:
                    output_string = "1111111111001"
                elif i == -6:
                    output_string = "1111111111010"
                elif i == -5:
                    output_string = "1111111111011"
                elif i == -4:
                    output_string = "1111111111100"
                elif i == -3:
                    output_string = "1111111111101"
                elif i == -2:
                    output_string = "1111111111110"
                elif i == -1:
                    output_string = "1111111111111"
                elif i == 0:
                    output_string = "0000000000000"
                elif i == 1:
                    output_string = "0000000000001"
                elif i == 2:
                    output_string = "0000000000010"
                elif i == 3:
                    output_string = "0000000000011"
                elif i == 4:
                    output_string = "0000000000100"
                elif i == 5:
                    output_string = "0000000000101"
                elif i == 6:
                    output_string = "0000000000110"
                elif i == 7:
                    output_string = "0000000000111"
                elif i == 8:
                    output_string = "0000000001000"
                elif i == 9:
                    output_string = "0000000001001"
                elif i == 10:
                    output_string = "0000000001010"
                elif i == 11:
                    output_string = "0000000001011"
                elif i == 12:
                    output_string = "0000000001100"
                elif i == 13:
                    output_string = "0000000001101"
                elif i == 14:
                    output_string = "0000000001110"
                elif i == 15:
                    output_string = "0000000001111"
                elif i == 16:
                    output_string = "0000000010000"
                elif i == 17:
                    output_string = "0000000010001"
                elif i == 18:
                    output_string = "0000000010010"
                elif i == 19:
                    output_string = "0000000010011"
                elif i == 20:
                    output_string = "0000000010100"
                elif i == 21:
                    output_string = "0000000010101"
                elif i == 22:
                    output_string = "0000000010110"
                elif i == 23:
                    output_string = "0000000010111"
                elif i == 24:
                    output_string = "0000000011000"
                elif i == 25:
                    output_string = "0000000011001"
                elif i == 26:
                    output_string = "0000000011010"
                elif i == 27:
                    output_string = "0000000011011"
                elif i == 28:
                    output_string = "0000000011100"
                elif i == 29:
                    output_string = "0000000011101"
                elif i == 30:
                    output_string = "0000000011110"
                elif i == 31:
                    output_string = "0000000011111"
                elif i == 32:
                    output_string = "0000000100000"
                elif i == 33:
                    output_string = "0000000100001"
                elif i == 34:
                    output_string = "0000000100010"
                elif i == 35:
                    output_string = "0000000100011"
                elif i == 36:
                    output_string = "0000000100100"
                elif i == -11:
                    output_string = "1111111110101"
                elif i == -12:
                    output_string = "1111111110100"
                elif i == -13:
                    output_string = "1111111110011"
                elif i == -14:
                    output_string = "1111111110010"
                elif i == -15:
                    output_string = "1111111110001"
                elif i == -16:
                    output_string = "1111111110000"
                elif i == -17:
                    output_string = "1111111101111"
                elif i == -18:
                    output_string = "1111111101110"
                elif i == -19:
                    output_string = "1111111101101"
                elif i == -20:
                    output_string = "1111111101100"
                elif i == -21:
                    output_string = "1111111101011"
                elif i == -22:
                    output_string = "1111111101010"
                elif i == -23:
                    output_string = "1111111101001"
                elif i == -24:
                    output_string = "1111111101000"
                elif i == -25:
                    output_string = "1111111100111"
                elif i == -26:
                    output_string = "1111111100110"
                elif i == -27:
                    output_string = "1111111100101"
                elif i == -28:
                    output_string = "1111111100100"
                elif i == -29:
                    output_string = "1111111100011"
                elif i == -30:
                    output_string = "1111111100010"
                elif i == -31:
                    output_string = "1111111100001"
                elif i == -32:
                    output_string = "1111111100000"
                elif i == -33:
                    output_string = "1111111011111"
                elif i == -34:
                    output_string = "1111111011110"
                elif i == -35:
                    output_string = "1111111011101"
                elif i == -36:
                    output_string = "1111111011100"


                f.write(output_string + '\n')
generate_systolic_array_data()