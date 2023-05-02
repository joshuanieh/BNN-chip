import torch
import torch.nn as nn
import random
data = torch.randn(1,6,3,3).sign()                  #Binarized input
conv2d = nn.Conv2d(6,1,3)
conv2d.weight.data = conv2d.weight.data.sign()      #Binarizing weight
conv2d.bias.data = torch.tensor([0])
output = conv2d(data)
print(output.data)