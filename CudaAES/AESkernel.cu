// main.cpp
#include "AES.cuh"

#include <chrono>
#include <cstdlib>



// Get File Name
std::string GetFileName(const std::string& filePath) {
    size_t lastSlash = filePath.find_last_of("/\\");
    if (lastSlash == std::string::npos) {
        return filePath;  // No slashes, return the whole string
    }
    return filePath.substr(lastSlash + 1);  // Return everything after the last slash
}

// Create file path (if dont exist)
std::string CreateFilePath(const std::string& folder, const std::string& fileName) {
    return folder + "/" + fileName;
}

// Function to append "_encrypted" or "_decrypted" to the file
std::string AppendToFileName(const std::string& filePath, const std::string& suffix) {
    size_t dotPosition = filePath.find_last_of('.');
    if (dotPosition == std::string::npos) {
        return filePath + suffix;  // No file extension, just append the suffix
    }
    else {
        return filePath.substr(0, dotPosition) + suffix + filePath.substr(dotPosition);  // Insert suffix before extension
    }
}

// remove the key if longer than 32 characters, or pad it with zero if shorter
void PadOrTruncateKey(unsigned char* key, const std::string& inputKey) {
    std::memset(key, 0, SIZE_32);  
    std::memcpy(key, inputKey.c_str(), std::min(inputKey.length(), static_cast<size_t>(SIZE_32)));
}

void DisplayAESExplanationkey(unsigned char* key) {
    const int expandedKeySizeDisplay = 240;

    // the expanded key
    unsigned char expandedKeyDisplay[expandedKeySizeDisplay];

    CreateExpandKey(expandedKeyDisplay, key, SIZE_32, expandedKeySizeDisplay);

    std::cout << "Expanded Key:\n";
    for (int i = 0; i < expandedKeySizeDisplay; i++) {
       
        if (i % 16 == 0) {
            std::cout << (i / 16 + 1) << ": ";  
        }

        std::cout << std::hex << std::setw(2) << std::setfill('0')
            << static_cast<int>(expandedKeyDisplay[i]);

        
        if ((i + 1) % 16 == 0) {
            std::cout << std::endl;  
        }
        else {
            std::cout << " ";  
        }
    }

}

bool FileExists(const std::string& path) {
    std::ifstream file(path);
    return file.good();
}

bool AskForKey(unsigned char* key) {
    std::string inputKey;
    std::cout << "Enter the AES key (up to 32 characters for AES-256): ";
    std::cin >> inputKey;

    if (inputKey.length() > SIZE_32) {
        std::cerr << "Key exceeds 32 characters, it will be truncated to 32 characters." << std::endl;
    }

  
    PadOrTruncateKey(key, inputKey);
    DisplayAESExplanationkey(key);
    std::cout << "\n";
    return true;
}

bool AskForFilePath(std::string& fileName) {
    std::cout << "Enter the file name in the 'FileToEncrypt' folder (e.g., example.txt): ";
    std::cin >> fileName;

    std::string inputFilePath = CreateFilePath("FileToEncrypt", fileName);
    if (!FileExists(inputFilePath)) {
        std::cerr << "File does not exist in 'FileToEncrypt' folder. Please try again." << std::endl;
        return false;
    }

    return true;
}

void EncryptProcess() {
    std::string fileName;
    unsigned char key[SIZE_32];

    // Ask for user the file name and key
    if (!AskForFilePath(fileName) || !AskForKey(key)) {
        return;
    }

    
    std::string inputFilePath = CreateFilePath("FileToEncrypt", fileName);
    std::string encryptedFilePath = CreateFilePath("EncryptFile", AppendToFileName(fileName, "_encrypted"));

    
    auto encryptionStart = std::chrono::high_resolution_clock::now();

    
    if (EncryptFile(inputFilePath, encryptedFilePath, key, SIZE_32)) {
        std::cout << "File encryption completed successfully! Encrypted file stored at: " << encryptedFilePath << std::endl;
    }
    else {
        std::cerr << "File encryption failed!" << std::endl;
        return;
    }

    auto encryptionEnd = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> encryptionDuration = encryptionEnd - encryptionStart;
    std::cout << "Time taken for encryption: " << encryptionDuration.count() << " seconds" << std::endl;
}

void DecryptProcess() {
    std::string fileName;
    unsigned char key[SIZE_32];

    
    std::cout << "Enter the encrypted file name (e.g., example_encrypted.bin): ";
    std::cin >> fileName;

    // Check file exist or not
    std::string encryptedFilePath = CreateFilePath("EncryptFile", fileName);
    if (!FileExists(encryptedFilePath)) {
        std::cerr << "File does not exist in 'EncryptFile' folder. Please try again." << std::endl;
        return;
    }

    std::string decryptedFilePath = CreateFilePath("DecryptFile", AppendToFileName(GetFileName(fileName), "_decrypted"));

    // Ask for user key
    if (!AskForKey(key)) {
        return;
    }

   
    auto decryptionStart = std::chrono::high_resolution_clock::now();

    
    if (DecryptFile(encryptedFilePath, decryptedFilePath, key, SIZE_32)) {
        std::cout << "File decryption completed successfully! Decrypted file stored at: " << decryptedFilePath << std::endl;
    }
    else {
        std::cerr << "File decryption failed!" << std::endl;
        return;
    }

    auto decryptionEnd = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> decryptionDuration = decryptionEnd - decryptionStart;
    std::cout << "Time taken for decryption: " << decryptionDuration.count() << " seconds" << std::endl;
}

int main(int argc, char* argv[]) {
    std::cout << "AES-256 File Encrpytion and Decrpytion\n " << std::endl;
    while (true) {
        int choice;
        std::cout << "Please choose an option: " << std::endl;
        std::cout << "1. Encrypt a file" << std::endl;
        std::cout << "2. Decrypt a file" << std::endl;
        std::cout << "0. Exit" << std::endl;
        std::cin >> choice;

        switch (choice) {
        case 1:
            EncryptProcess();
            break;
        case 2:
            DecryptProcess();
            break;
        case 0:
            std::cout << "Exiting program..." << std::endl;
            return 0;
        default:
            std::cerr << "Invalid choice. Please try again." << std::endl;
            break;
        }
    }

    return 0;
}



