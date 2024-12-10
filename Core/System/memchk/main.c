/* ****************************************
   memchk.exe
   
   A quick and dirty applet to retrieve physical memory amounts on MS systems
   returns a string to be parsed in MATLAB for memory processing in CPCA
   
   String format: Total: nnnn Avail: nnnn
   Tab delimiter between Total mem and Available Mem
   memory size displayed as MB
   
   Notes: - only returns physical memory - no virtual or pagefile sizing
          - only tested on Windows XP - Vista capability untested
          - Vista or 64 bit computers may need to recompile the applet
              download dev-cpp from bloodshed software ( www.bloodshed.com/devcpp.html )
              install dev-cpp, open the memchk project file and rebuild
              
              
     Windows 7        _WIN32_WINNT_WIN7        0x0601
     Windows 2008     _WIN32_WINNT_WS08        0x0600
     Windows Vista    _WIN32_WINNT_VISTA       0x0600
     Windows XP SP2   _WIN32_WINNT_WS03        0x0502
     Windows XP       _WIN32_WINNT_WINXP       0x0501
     Windows 2000     _WIN32_WINNT_WIN2K       0x0500
                   
   **************************************** */
#define _WIN32_WINNT 0x0500

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

//typedef void (WINAPI *PGNSI)(LPSYSTEM_INFO);
//typedef void (WINAPI *PGPI) (DWORD, DWORD, DWORD, DWORD, PDWORD );

int main(int argc, char *argv[])
{
    
/*  OSVERSIONINFOEX osvi;
  BOOL bosVersionInfoEx;
  SYSTEM_INFO si;
*/ 
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof( statex );
  GlobalMemoryStatusEx( &statex);

/*  osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
  bosVersionInfoEx = GetVersionEx( (OSVERSIONINFO*) &osvi );
  
  if (bosVersionInfoEx ) {
    GetSystemInfo(&si);
  }
*/
  printf( "Total: %I64u\tAvail: %I64u \n", (DWORDLONG)statex.ullTotalPhys/1024000, (DWORDLONG)statex.ullAvailPhys/10240000 );
//  printf( "PageFile Total: %I64u\tAvail: %I64u \n", statex.ullTotalPageFile, statex.ullAvailPageFile );
//  printf( "Virtual Total: %I64u\tAvail: %I64u \n", statex.ullTotalVirtual, statex.ullAvailVirtual );
  
//  system("PAUSE");	
  return 0;
}


