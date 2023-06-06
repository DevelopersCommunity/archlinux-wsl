//
//    Copyright (C) Microsoft.  All rights reserved.
// Licensed under the terms described in the LICENSE file in the root of this project.
//

#include "stdafx.h"

bool DistributionInfo::CreateUser(std::wstring_view userName)
{
    // Create the user account.
    DWORD exitCode;
    std::wstring commandLine = L"/bin/useradd -m -U -G wheel ";
    commandLine += userName;
    HRESULT hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    commandLine = L"/bin/passwd ";
    commandLine += userName;
    const wchar_t* passwd = commandLine.c_str();
    do
    {
        hr = g_wslApi.WslLaunchInteractive(passwd, true, &exitCode);
    } while ((FAILED(hr)) || (exitCode != 0));

    return true;
}

bool DistributionInfo::InitializePacman()
{
    // https://wiki.archlinux.org/title/Reflector
    DWORD exitCode;
    std::wstring commandLine = L"/bin/systemctl enable --now reflector.timer";
    HRESULT hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    // https://wiki.archlinux.org/title/Pacman/Package_signing#Resetting_all_the_keys
    commandLine = L"/bin/pacman-key --init";
    hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    commandLine = L"/bin/pacman-key --populate archlinux";
    hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    commandLine = L"/bin/pacman -S --noconfirm --needed archlinux-keyring";
    hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    return true;
}

bool DistributionInfo::EnableChrony()
{
    DWORD exitCode;
    std::wstring commandLine = L"/bin/systemctl enable --now chronyd.service";
    HRESULT hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    return true;
}

bool DistributionInfo::GenerateDBusUuid()
{
    DWORD exitCode;
    std::wstring commandLine = L"/bin/dbus-uuidgen --ensure=/etc/machine-id";
    HRESULT hr = g_wslApi.WslLaunchInteractive(commandLine.c_str(), true, &exitCode);
    if ((FAILED(hr)) || (exitCode != 0)) {
        return false;
    }

    return true;
}

ULONG DistributionInfo::QueryUid(std::wstring_view userName)
{
    // Create a pipe to read the output of the launched process.
    HANDLE readPipe;
    HANDLE writePipe;
    SECURITY_ATTRIBUTES sa{sizeof(sa), nullptr, true};
    ULONG uid = UID_INVALID;
    if (CreatePipe(&readPipe, &writePipe, &sa, 0)) {
        // Query the UID of the supplied username.
        std::wstring command = L"/bin/id -u ";
        command += userName;
        int returnValue = 0;
        HANDLE child;
        HRESULT hr = g_wslApi.WslLaunch(command.c_str(), true, GetStdHandle(STD_INPUT_HANDLE), writePipe, GetStdHandle(STD_ERROR_HANDLE), &child);
        if (SUCCEEDED(hr)) {
            // Wait for the child to exit and ensure process exited successfully.
            WaitForSingleObject(child, INFINITE);
            DWORD exitCode;
            if ((GetExitCodeProcess(child, &exitCode) == false) || (exitCode != 0)) {
                hr = E_INVALIDARG;
            }

            CloseHandle(child);
            if (SUCCEEDED(hr)) {
                char buffer[64]{};
                DWORD bytesRead;

                // Read the output of the command from the pipe and convert to a UID.
                if (ReadFile(readPipe, buffer, (sizeof(buffer) - 1), &bytesRead, nullptr)) {
                    buffer[bytesRead] = ANSI_NULL;
                    try {
                        uid = std::stoul(buffer, nullptr, 10);

                    } catch( ... ) { }
                }
            }
        }

        CloseHandle(readPipe);
        CloseHandle(writePipe);
    }

    return uid;
}
