<p align="center">
<a href="https://www.powershellgallery.com/packages/OutTabulatorView"><img
src="https://img.shields.io/powershellgallery/v/OutTabulatorView.svg"></a>
<a href="https://www.powershellgallery.com/packages/OutTabulatorView"><img
src="https://img.shields.io/powershellgallery/dt/OutTabulatorView.svg"></a>
<a href="./LICENSE.txt"><img
src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
</p>

# OutTabulatorView
PowerShell - Sending output to an interactive table in a browser

Grab it from the [PowerShell Gallery](https://www.powershellgallery.com/packages/OutTabulatorView)

## What's New 1.2.0

Now handles large datasets much better thank you [RoYoMi](https://github.com/RoYoMi)!

A 10k item dataset used to take ~2 seconds to load, now it sub second!

## What's New 1.1.0

- Thank you to [ViperTG](https://github.com/ViperTG) for the pull request : File encoding changed to UTF8 to support characters like `æøå`

```powershell
Install-Module -Name OutTabulatorView
```

## Get Started

```powershell
ps | Select Company, Name, Handles | otv -groupBy Company
```

## In Action
![](https://raw.githubusercontent.com/dfinke/OutTabulatorView/master/images/otv.gif?token=AAEGunJ7iPFmCGiZRXph7UMcgyX8kyaNks5bFVEHwA%3D%3D)
