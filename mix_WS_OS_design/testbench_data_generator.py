'''
Mix WS OS Design Testbench
Generate image with size 4 by 6, input three channels and output 64 channels 
'''
import torch
import torch.nn as nn
import random
def generate_mix_os_ws_data():
    data = torch.randn(1,3,3,6).sign()                  #Simpified case, no another reset (next four pixels)
    conv2d = nn.Conv2d(3,64,3, bias=False)
    conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
    output = conv2d(data)
    # print(data[0][0])
    # print(conv2d.weight.data)
    # print(output.shape)
    
    with open('data.dat', 'w') as f:
        #Output pixel 0~3
        #First channel
        weight_list = [kernel[0].flatten().tolist() for kernel in conv2d.weight.data]
        # f.write('load_weight\n')
        for d in weight_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        # f.write('in_valid\n')
        data_list = [[data[0][0][i][j+k].item() for i in range(3) for j in range(3)] for k in range(4)]
        for d in data_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        #Second channel
        weight_list = [kernel[1].flatten().tolist() for kernel in conv2d.weight.data]
        # f.write('load_weight\n')
        for d in weight_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        # f.write('in_valid\n')
        data_list = [[data[0][1][i][j+k].item() for i in range(3) for j in range(3)] for k in range(4)]
        for d in data_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        #Third channel
        weight_list = [kernel[2].flatten().tolist() for kernel in conv2d.weight.data]
        # f.write('load_weight\n')
        for d in weight_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        # f.write('in_valid\n')
        data_list = [[data[0][2][i][j+k].item() for i in range(3) for j in range(3)] for k in range(4)]
        for d in data_list:
            data_string = ""
            for b in d:
                if b == -1:
                    data_string += '0'
                else:
                    data_string += '1'

            f.write(data_string + '\n')

        # f.write('pop\n')

    with open('golden.dat', 'w') as f:
        for och in output[0]:
            output_list = och.flatten().tolist() 
            for num in output_list:
                i = int(num)
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
    
    # with open('data.dat', 'w') as f:
    #     for i in data_list:
    #         data_string = ""
    #         for j in i:
    #             if j == -1:
    #                 data_string += '0'
    #             else:
    #                 data_string += '1'

    #         f.write("".join(data_string) + '\n')

    # with open('weight.dat', 'w') as f:
    #     for i in weight_list:
    #         weight_string = ""
    #         for j in i:
    #             if j == -1:
    #                 weight_string += '0'
    #             else:
    #                 weight_string += '1'

    #         f.write("".join(weight_string) + '\n')
            
            
    # with open('golden.dat', 'w') as f:
    #     for i in output_list:
    #         output_string = ""
    #         if i == -9:
    #             output_string = "1110111"
    #         elif i == -8:
    #             output_string = "1111000"
    #         elif i == -7:
    #             output_string = "1111001"
    #         elif i == -6:
    #             output_string = "1111010"
    #         elif i == -5:
    #             output_string = "1111011"
    #         elif i == -4:
    #             output_string = "1111100"
    #         elif i == -3:
    #             output_string = "1111101"
    #         elif i == -2:
    #             output_string = "1111110"
    #         elif i == -1:
    #             output_string = "1111111"
    #         elif i == 0:
    #             output_string = "0000000"
    #         elif i == 1:
    #             output_string = "0000001"
    #         elif i == 2:
    #             output_string = "0000010"
    #         elif i == 3:
    #             output_string = "0000011"
    #         elif i == 4:
    #             output_string = "0000100"
    #         elif i == 5:
    #             output_string = "0000101"
    #         elif i == 6:
    #             output_string = "0000110"
    #         elif i == 7:
    #             output_string = "0000111"
    #         elif i == 8:
    #             output_string = "0001000"
    #         elif i == 9:
    #             output_string = "0001001"

    #         f.write(output_string + '\n')
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


generate_mix_os_ws_data()
#A = numpy.array([[20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],[-13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [-1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6, -1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13, 6], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20, -13], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 6, -13, 20]])