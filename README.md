# Power Automate Desktop — Hello World Custom Action

A minimal Proof of Concept demonstrating how to create, build, sign, package, upload,
and use a custom action in Power Automate Desktop.

## What This Does

The **Hello World** custom action:
- **Input**: `YourName` (string, defaults to "World")
- **Output**: `GreetingMessage` → `"Hello, {YourName}!"`

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **Power Automate Desktop** | v2.32 or later installed on your machine |
| **Power Platform access** | Access to [make.powerautomate.com](https://make.powerautomate.com) |
| **Role** | "Desktop Flow Module Developer" role in Power Platform admin center |
| **License** | Attended RPA license (to include/use custom actions) |
| **.NET SDK** | Already used to build — no additional setup needed |
| **Windows SDK** | signtool.exe (already found on this machine) |

## Quick Start (Step by Step)

### Step 1: Build the Project

```powershell
cd C:\Users\mikan\source\repos\ppcustom
dotnet build -c Release
```

Verify output at `bin\Release\net472\Modules.HelloWorld.dll`.

### Step 2: Create a Self-Signed Certificate (PoC Only)

> ⚠️ **For production**, use a certificate trusted by your organization.

```powershell
.\scripts\createTestCert.ps1
```

This creates:
- A code signing cert in your user certificate store
- `HelloWorldCert.pfx` in the project root
- Installs the cert into Trusted Root CA and Trusted Publisher stores

### Step 3: Sign DLLs, Package, and Sign the .cab

```powershell
.\scripts\signAndPackage.ps1
```

This:
1. Signs all DLLs (except the SDK DLL) with the PFX certificate
2. Packages them into `output\Modules.HelloWorld.cab`
3. Signs the .cab file

### Step 4: Upload to Power Platform

1. Go to [make.powerautomate.com](https://make.powerautomate.com)
2. In the left nav, select **Data** → **Custom actions**
3. Click **Upload custom action**
4. Fill in:
   - **Name**: `Hello World`
   - **Description**: `A simple greeting action for testing`
   - **Select file**: Browse to `output\Modules.HelloWorld.cab`
5. Click **Upload**

### Step 5: Use in Power Automate Desktop

1. Open **Power Automate Desktop** designer
2. Create a new flow (or open an existing one)
3. Click **Assets Library** (in the toolbar or under Tools)
4. Go to the **Custom Actions** tab
5. Find "Hello World" and click **Add** (include it in your flow)
6. Close the Assets Library
7. In the **Actions** pane, expand **Custom Actions** at the bottom
8. Drag **Hello World** into your flow
9. Set **Your Name** to any value (or leave the default "World")
10. Add a **Display message** action after it, using `%GreetingMessage%` as the message
11. **Run** the flow — you should see "Hello, World!" (or your custom name)

## Project Structure

```
ppcustom\
├── Modules.HelloWorld.csproj    # .NET Framework 4.7.2 class library
├── HelloWorldAction.cs          # The custom action implementation
├── HelloWorldCert.pfx           # Self-signed cert (created by script)
├── output\
│   └── Modules.HelloWorld.cab   # Signed .cab ready for upload
├── scripts\
│   ├── createTestCert.ps1       # Creates self-signed code signing cert
│   ├── makeCabFile.ps1          # Packages DLLs into .cab
│   └── signAndPackage.ps1       # All-in-one: sign DLLs + package + sign .cab
└── README.md                    # This file
```

## Key Concepts

- **Assembly naming**: Must match `Modules.*` or `*.Modules.*` pattern for PAD to recognize it
- **ActionBase**: All custom actions inherit from `ActionBase` and override `Execute()`
- **Attributes**: `[Action]`, `[InputArgument]`, `[OutputArgument]` define how PAD presents the action
- **Signing**: All DLLs AND the .cab must be signed with a trusted certificate
- **Packaging**: The SDK DLL is automatically excluded from the .cab (PAD provides it)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Custom action not visible | Ensure it's shared with you and you have the correct role |
| Upload fails | Check that both DLLs and .cab are signed with a trusted cert |
| Action errors at runtime | Ensure the cert is in Trusted Root CA on the machine running the flow |
| "Module not found" | Verify assembly name follows `Modules.*` pattern |

## References

- [Create custom actions](https://learn.microsoft.com/en-us/power-automate/desktop-flows/create-custom-actions)
- [Upload custom actions](https://learn.microsoft.com/en-us/power-automate/desktop-flows/upload-custom-actions)
- [Use custom actions](https://learn.microsoft.com/en-us/power-automate/desktop-flows/use-custom-actions)
