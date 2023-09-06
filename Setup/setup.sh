sudo apt-get install git -y
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev         libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo     gperf libtool patchutils bc zlib1g-dev git libexpat1-dev gtkwave -y

cd
pwd=$PWD
mkdir riscv_toolchain
cd riscv_toolchain

wget "https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz"
tar -xvzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz 
export PATH=$pwd/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
sudo apt-get install device-tree-compiler -y

git clone https://github.com/riscv/riscv-isa-sim.git
cd riscv-isa-sim/
mkdir build
cd build
../configure --prefix=$pwd/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14
make
sudo make install
cd $pwd/riscv_toolchain

git clone https://github.com/riscv/riscv-pk.git
cd riscv-pk/
mkdir build
cd build/
../configure --prefix=$pwd/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 --host=riscv64-unknown-elf
make
sudo make install
export PATH=$pwd/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH

cd $pwd/riscv_toolchain

git clone https://github.com/steveicarus/iverilog.git
cd iverilog/
git checkout --track -b v12-branch origin/v12-branch
git pull 
chmod +x autoconf.sh 
./autoconf.sh 
./configure 
make
sudo make install 