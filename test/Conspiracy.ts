import { ethers, upgrades } from 'hardhat'
import { expect } from 'chai'

describe('Conspiracy contract tests', () => {
  let Conspiracy, conspiracy, owner

  before(async function () {
    ;[owner] = await ethers.getSigners()
    Conspiracy = await ethers.getContractFactory('Conspiracy')
    conspiracy = await upgrades.deployProxy(Conspiracy, [
      owner.address,
      '$🤫',
      '🤫',
      1,
      ethers.parseUnits('1000000', 18),
      ethers.ZeroAddress,
    ])
  })

  describe('Initialization', function () {
    it('should have correct initial values', async function () {
      expect(await conspiracy.name()).to.equal('$🤫')
      expect(await conspiracy.symbol()).to.equal('🤫')
    })
  })
})
