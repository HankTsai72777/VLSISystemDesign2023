void boot() {
	extern unsigned int _dram_i_start;//instruction start address in DRAM
	extern unsigned int _dram_i_end;//instruction end address in DRAM
	extern unsigned int _imem_start;//instruction start address in IM

	extern unsigned int __sdata_start;//Main_data start address in DM
	extern unsigned int __sdata_end;//Main_data end address in DM
	extern unsigned int __sdata_paddr_start;//Main_data start address in DRAM

	extern unsigned int __data_start;//Main_data start address in DM
	extern unsigned int __data_end;//Main_data end address in DM
	extern unsigned int __data_paddr_start;//Main_data start address in DRAM

	unsigned int d1 = (&_dram_i_end)-(&_dram_i_start);
	unsigned int d2 = (&__sdata_end)-(&__sdata_start);
	unsigned int d3 = (&__data_end)-(&__data_start);
	unsigned int i;
	
	for(i=0;i<=(d1);i++){
	  *((&_imem_start)+i)=*((&_dram_i_start)+i);
	}
	for(i=0;i<=(d2);i++){
	  *((&__sdata_start)+i)=*((&__sdata_paddr_start)+i);
	}
	for(i=0;i<=(d3);i++){
	  *((&__data_start)+i)=*((&__data_paddr_start)+i);
	}
}
